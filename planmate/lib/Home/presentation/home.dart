// import 'package:flutter/material.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             if (user?.photoURL != null) ...[
//               CircleAvatar(
//                 radius: 20,
//                 backgroundImage: NetworkImage(user!.photoURL!),
//               ),
//               const SizedBox(width: 10),
//             ],

//             if (user?.displayName != null) ...[
//               Text(
//                 user!.displayName!,
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
