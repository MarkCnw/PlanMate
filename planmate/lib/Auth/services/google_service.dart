import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ฟังก์ชันสำหรับ Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      // เริ่มต้นกระบวนการ Google Sign-In
      final GoogleSignInAccount? googleSignInAccount = 
          await _googleSignIn.signIn();
      
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // ลงชื่อเข้าใช้ Firebase ด้วย Google credentials
        final UserCredential userCredential = 
            await _auth.signInWithCredential(authCredential);

        // บันทึกข้อมูลผู้ใช้ลง Firestore (หากยังไม่มี)
        if (userCredential.user != null) {
          await _saveUserToFirestore(userCredential.user!);
        }
      }
    } on FirebaseAuthException catch (e) {
      throw Exception('Firebase Auth Error: ${e.message}');
    } catch (e) {
      throw Exception('Google Sign-In Error: ${e.toString()}');
    }
  }

  // ฟังก์ชันสำหรับ Sign Out
  Future<void> googleSignOut() async {
    try {
      // ออกจากระบบ Google และ Firebase
      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
      ]);
    } catch (e) {
      throw Exception('Sign out error: ${e.toString()}');
    }
  }

  // ฟังก์ชันสำหรับบันทึกข้อมูลผู้ใช้ลง Firestore
  Future<void> _saveUserToFirestore(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      
      // เช็คว่าผู้ใช้มีข้อมูลใน Firestore แล้วหรือไม่
      final docSnapshot = await userDoc.get();
      
      if (!docSnapshot.exists) {
        // สร้างข้อมูลผู้ใช้ใหม่
        await userDoc.set({
          'uid': user.uid,
          'name': user.displayName ?? '',
          'photoURL': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'lastSignIn': FieldValue.serverTimestamp(),
        });
      } else {
        // อัปเดตเวลาล็อกอินล่าสุด
        await userDoc.update({
          'lastSignIn': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error saving user to Firestore: ${e.toString()}');
      // ไม่ throw error เพราะไม่ต้องการให้การ sign in ล้มเหลว
    }
  }

  // ฟังก์ชันสำหรับเช็คสถานะการเข้าสู่ระบบ
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Stream สำหรับติดตามการเปลี่ยนแปลงสถานะการเข้าสู่ระบบ
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}