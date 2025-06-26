import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseServices {
  final auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final userCredential = await auth.signInWithCredential(authCredential);

        // ✅ บันทึก UID ลง SharedPreferences
        await _saveUserId(userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      print(e.toString());
    }
  }

  Future<void> googleSignOut() async {
    await googleSignIn.signOut();
    await auth.signOut();

    // ✅ ล้างข้อมูลใน SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_uid');
    // await prefs.remove('selected_avatar'); // ถ้าต้องการให้ล้าง avatar ด้วย
  }

  Future<void> _saveUserId(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_uid', uid);
  }
}
