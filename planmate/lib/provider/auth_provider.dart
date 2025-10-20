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

    // ✅ ใช้ userChanges() แทน idTokenChanges() - ครอบคลุมทุกการเปลี่ยนแปลง
    _authSub = _auth.userChanges().listen((user) {
      debugPrint('🔔 Auth user changed: ${user?.uid}');
      final wasAuthenticated = _currentUser != null;
      final isNowAuthenticated = user != null;

      _currentUser = user;

      // ✅ แจ้ง listeners ทุกครั้งที่ auth state เปลี่ยน
      if (wasAuthenticated != isNowAuthenticated) {
        debugPrint(
          '✅ Authentication state changed! Notifying listeners...',
        );
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
        // ===== WEB =====
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

        // ✅ อัปเดต currentUser และแจ้ง listeners
        _currentUser = _auth.currentUser;
        _setLoading(false);

        // ✅ Force notify เพื่อให้ AuthWrapper rebuild ทันที
        notifyListeners();

        debugPrint(
          '✅ Sign in successful - currentUser: ${_currentUser?.uid}',
        );
        return true;
      } else {
        // ===== ANDROID/iOS =====
        debugPrint('📱 Starting Google Sign In for mobile...');

        // ✅ ลองใช้ signInSilently ก่อน (สำหรับ returning user)
        GoogleSignInAccount? googleAcc;

        try {
          googleAcc = await _googleSignIn.signInSilently();
          debugPrint('🔄 Silent sign in result: ${googleAcc?.email}');
        } catch (silentError) {
          debugPrint('⚠️ Silent sign in failed: $silentError');
        }

        // ถ้า silent sign in ไม่สำเร็จ ให้แสดง UI
        if (googleAcc == null) {
          debugPrint('🔄 Showing Google Sign In UI...');
          googleAcc = await _googleSignIn.signIn();
        }

        if (googleAcc == null) {
          debugPrint('⚠️ User cancelled Google Sign In');
          _setLoading(false);
          return false;
        }

        debugPrint('✅ Google account selected: ${googleAcc.email}');

        // ✅ ดึง authentication credentials
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

        // ✅ CRITICAL: อัปเดต state และแจ้ง listeners
        _currentUser = _auth.currentUser;
        debugPrint('✅ Updated currentUser: ${_currentUser?.uid}');
        debugPrint('✅ isAuthenticated: $isAuthenticated');

        _setLoading(false);

        // ✅ Force notify เพื่อให้ AuthWrapper rebuild ทันที
        notifyListeners();

        // ✅ รอให้ widget tree rebuild
        await Future.delayed(const Duration(milliseconds: 100));

        debugPrint('✅ Sign in process completed successfully!');
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
        } catch (_) {
          debugPrint(
            '⚠️ Google disconnect failed (might not be connected)',
          );
        }
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
