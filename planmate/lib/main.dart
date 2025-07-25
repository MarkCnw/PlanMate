import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:planmate/Navigation/presentation/navigation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:planmate/Auth/presentation/login_screen.dart';

import 'package:planmate/Onboarding/Presentation/onboarding_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PlanMate',
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  // เช็คว่าเคยเห็น Onboarding แล้วหรือยัง
  Future<bool> _hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_onboarding') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // แสดง loading ขณะกำลังเช็คสถานะ
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // ถ้ามี user แสดงว่าเข้าสู่ระบบแล้ว -> ไปหน้า Home
        if (snapshot.hasData && snapshot.data != null) {
          return const CustomBottomNavBarApp();
        }
        
        // ถ้าไม่มี user -> เช็คว่าเคยเห็น Onboarding หรือยัง
        return FutureBuilder<bool>(
          future: _hasSeenOnboarding(),
          builder: (context, onboardingSnapshot) {
            if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            // ถ้าเคยเห็น Onboarding แล้ว -> ไปหน้า Login
            if (onboardingSnapshot.data == true) {
              return const SignInScreen();
            }
            
            // ถ้าไม่เคยเห็น Onboarding -> ไปหน้า Onboarding
            return const OnboardingScreen();
          },
        );
      },
    );
  }
}