// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthServicews {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<String> signUpUser({
//     required String email,
//     required String password,
//     required String name,
//   }) async {
//     String res = "some error occurred";
//     try {
//       if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
//         UserCredential credential = await _auth
//             .createUserWithEmailAndPassword(email: email, password: password);

//         await _firestore.collection("users").doc(credential.user!.uid).set({
//           "name": name,
//           "email": email,
//           "uid": credential.user!.uid,
//         });

//         // บันทึก UID ลง SharedPreferences
//         await _saveUserId(credential.user!.uid);

//         res = "success";
//       } else {
//         res = "Please fill all the fields";
//       }
//     } catch (e) {
//       return e.toString();
//     }
//     return res;
//   }

//   Future<String> loginUser({
//     required String email,
//     required String password,
//   }) async {
//     String res = "some error occurred";
//     try {
//       if (email.isNotEmpty && password.isNotEmpty) {
//         UserCredential credential = await _auth.signInWithEmailAndPassword(
//           email: email,
//           password: password,
//         );

//         // บันทึก UID ลง SharedPreferences
//         await _saveUserId(credential.user!.uid);

//         res = "success";
//       } else {
//         res = "Please fill all the fields";
//       }
//     } catch (e) {
//       return e.toString();
//     }
//     return res;
//   }

//   Future<void> sigOut() async {
//     await _auth.signOut();

//     // ลบ uid ออกจาก SharedPreferences
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('user_uid');
//     await prefs.remove('selected_avatar'); // ถ้าต้องการให้ลบ avatar ด้วย
//   }

//   Future<void> _saveUserId(String uid) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('user_uid', uid);
//   }
// }
