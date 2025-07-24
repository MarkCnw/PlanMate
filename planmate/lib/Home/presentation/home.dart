import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planmate/Auth/presentation/login_screen.dart';
import 'package:planmate/Auth/services/google_service.dart';


import 'package:planmate/Widgets/bunton.dart';
// เพิ่ม import

class HomeScreen extends StatelessWidget {
  
  
  const HomeScreen({
    super.key,
    
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWelcomeText(),
              const SizedBox(height: 30),
              _buildUserInfoSection(user),
              const SizedBox(height: 30),
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return const Text(
      "Congratulations!\nYou have successfully logged in",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  

  Widget _buildUserInfoSection(User? user) {
    return Column(
      children: [
        // แสดงรูปโปรไฟล์ (ถ้ามีจาก Google)
        // if (user?.photoURL != null) ...[
        //   CircleAvatar(
        //     radius: 40,
        //     backgroundImage: NetworkImage(user!.photoURL!),
        //   ),
        //   const SizedBox(height: 10),
        // ],

        // แสดงชื่อผู้ใช้ (ถ้ามี)
        if (user?.displayName != null) ...[
          Text(
            user!.displayName!,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // แสดงอีเมล (ถ้ามี)
        if (user?.email != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              user!.email!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return MyButton(
      onTab: () async {
        await _handleLogout(context);
      },
      text: "Log Out",
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // ออกจากระบบ
      await FirebaseServices().googleSignOut();
      
      // นำทางกลับไปหน้า Login
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SignInScreen(),
          ),
        );
      }
    } catch (e) {
      // Handle logout error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}