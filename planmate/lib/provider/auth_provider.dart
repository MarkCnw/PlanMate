import 'dart:async';
import 'package:flutter/foundation.dart'
    show ChangeNotifier, debugPrint, kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  StreamSubscription<User?>? _authSub;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initialize();
  }

  void _initialize() {
    debugPrint('🔄 AuthProvider: Initializing...');
    _currentUser = _auth.currentUser;
    debugPrint('📍 Initial user: ${_currentUser?.uid}');

    // ✅ ใช้ idTokenChanges ครอบคลุมกว่า authStateChanges
    _authSub = _auth.idTokenChanges().listen((user) {
      debugPrint('🔔 Auth token/state changed: ${user?.uid}');
      if (_currentUser?.uid != user?.uid) {
        _currentUser = user;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    clearError();
    try {
      debugPrint('🔄 Starting Google Sign In...');

      if (kIsWeb) {
        final provider =
            GoogleAuthProvider()
              ..addScope('email')
              ..addScope('profile');

        final cred = await _auth.signInWithPopup(provider);
        debugPrint(
          '✅ Firebase sign in (web) successful: ${cred.user?.uid}',
        );
        if (cred.user != null) {
          await _saveUserToFirestore(cred.user!);
        }

        // ✅ บังคับอัปเดต + แจ้ง UI ทันที
        _currentUser = _auth.currentUser;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        // Android/iOS
        final GoogleSignInAccount? googleAcc =
            await _googleSignIn.signIn();
        if (googleAcc == null) {
          debugPrint('⚠️ User cancelled Google Sign In');
          _setLoading(false);
          return false;
        }

        debugPrint('✅ Google account selected: ${googleAcc.email}');
        final GoogleSignInAuthentication authData =
            await googleAcc.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: authData.accessToken,
          idToken: authData.idToken,
        );

        debugPrint('🔄 Signing in to Firebase...');
        final userCred = await _auth.signInWithCredential(credential);
        debugPrint('✅ Firebase sign in successful: ${userCred.user?.uid}');

        if (userCred.user != null) {
          await _saveUserToFirestore(userCred.user!);
        }

        // ✅ จุดสำคัญ: อัปเดต state + notify ให้ AuthWrapper รีบิลด์ไปหน้า Home
        _currentUser = _auth.currentUser;
        debugPrint(
          '✅ Firebase currentUser after signIn: ${_currentUser?.uid}',
        );
        _setLoading(false);
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      _setLoading(false);
      _setError(_mapFirebaseAuthError(e));
      return false;
    } on Exception catch (e) {
      final msg = e.toString();
      debugPrint('❌ Google Sign-In Error: $msg');
      _setLoading(false);

      if (msg.contains('com.google.android.gms') ||
          msg.contains('Google Play services') ||
          msg.contains('Unknown calling package name')) {
        _setError(
          'อุปกรณ์นี้ไม่มี/ไม่พร้อม Google Play services.\n'
          'ใช้ Emulator ที่เป็น Google Play image หรืออัปเดต Google Play services\n'
          'และตรวจสอบว่าได้เพิ่ม SHA-1 debug keystore ใน Firebase Console แล้ว',
        );
      } else {
        _setError('เกิดข้อผิดพลาดในการเข้าสู่ระบบ: $msg');
      }
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('🔄 Signing out...');
      _setLoading(true);
      clearError();

      if (!kIsWeb) {
        try {
          await _googleSignIn.disconnect();
        } catch (_) {}
        await _googleSignIn.signOut();
      }
      await _auth.signOut();

      _currentUser = null;
      _setLoading(false);
      notifyListeners();
      debugPrint('✅ Sign out successful');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      _setLoading(false);
      _setError('เกิดข้อผิดพลาดในการออกจากระบบ: $e');
    }
  }

  Future<void> _saveUserToFirestore(User user) async {
    try {
      debugPrint('🔄 Saving user to Firestore: ${user.uid}');
      final userDoc = _firestore.collection('users').doc(user.uid);
      final snap = await userDoc.get();

      if (!snap.exists) {
        debugPrint('📝 Creating new user document');
        await userDoc.set({
          'uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'photoURL': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'lastSignIn': FieldValue.serverTimestamp(),
        });
      } else {
        debugPrint('📝 Updating last sign in time');
        await userDoc.update({'lastSignIn': FieldValue.serverTimestamp()});
      }
      debugPrint('✅ User document saved/updated');
    } catch (e) {
      debugPrint('❌ Error saving user to Firestore: $e');
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'บัญชีนี้ถูกใช้งานแล้วด้วยวิธีอื่น';
      case 'invalid-credential':
        return 'ข้อมูลการเข้าสู่ระบบไม่ถูกต้อง';
      case 'operation-not-allowed':
        return 'การเข้าสู่ระบบด้วย Google ไม่ได้รับอนุญาต';
      case 'user-disabled':
        return 'บัญชีนี้ถูกปิดใช้งาน';
      case 'user-not-found':
        return 'ไม่พบบัญชีนี้';
      case 'wrong-password':
        return 'รหัสผ่านไม่ถูกต้อง';
      case 'network-request-failed':
        return 'เกิดปัญหาการเชื่อมต่อเครือข่าย';
      case 'popup-closed-by-user':
        return 'ปิดหน้าต่างเข้าสู่ระบบก่อนเสร็จสิ้น';
      default:
        return 'เกิดข้อผิดพลาด: ${e.message ?? e.code}';
    }
  }

  String get displayName => _currentUser?.displayName ?? 'User';
  String get email => _currentUser?.email ?? '';
  String? get photoURL => _currentUser?.photoURL;
  String? get userId => _currentUser?.uid;

  void printAuthState() {
    debugPrint('========== AUTH STATE ==========');
    debugPrint('Is Authenticated: $isAuthenticated');
    debugPrint('User ID: $userId');
    debugPrint('Email: $email');
    debugPrint('Display Name: $displayName');
    debugPrint('Is Loading: $isLoading');
    debugPrint('Error: $error');
    debugPrint('================================');
  }
}
