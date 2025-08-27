import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State variables
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Constructor
  AuthProvider() {
    _initialize();
  }

  // Initialize auth state listener
  void _initialize() {
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });

    // Set initial user
    _currentUser = _auth.currentUser;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error state
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      clearError();

      // Start Google Sign In process
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount == null) {
        // User cancelled sign in
        _setLoading(false);
        return false;
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // Sign in to Firebase with Google credentials
      final UserCredential userCredential = await _auth
          .signInWithCredential(authCredential);

      // Save user data to Firestore
      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
      }

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError('Firebase Auth Error: ${e.message}');
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Google Sign-In Error: ${e.toString()}');
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      clearError();

      // Sign out from both Google and Firebase
      await Future.wait([_googleSignIn.signOut(), _auth.signOut()]);

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('Sign out error: ${e.toString()}');
    }
  }

  // Save user to Firestore
  Future<void> _saveUserToFirestore(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);

      // Check if user document exists
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        // Create new user document
        await userDoc.set({
          'uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'photoURL': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'lastSignIn': FieldValue.serverTimestamp(),
        });
      } else {
        // Update last sign in time
        await userDoc.update({'lastSignIn': FieldValue.serverTimestamp()});
      }
    } catch (e) {
      debugPrint('Error saving user to Firestore: ${e.toString()}');
      // Don't throw error as sign in should still succeed
    }
  }

  // Check if user has seen onboarding
  Future<bool> hasSeenOnboarding() async {
    // This would typically use SharedPreferences
    // For now, we'll implement a simple check
    return true; // Implement based on your needs
  }

  // Get user display name
  String get displayName {
    return _currentUser?.displayName ?? 'User';
  }

  // Get user email
  String get email {
    return _currentUser?.email ?? '';
  }

  // Get user photo URL
  String? get photoURL {
    return _currentUser?.photoURL;
  }

  // Get user ID
  String? get userId {
    return _currentUser?.uid;
  }
}
