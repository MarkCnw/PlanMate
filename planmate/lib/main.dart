import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planmate/History/Provider/history_provider.dart';

import 'package:planmate/provider/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Services/noti.dart';
import 'firebase_options.dart';

// ==== Layers ====
import 'package:planmate/provider/auth_provider.dart';
import 'package:planmate/provider/project_provider.dart';

// ==== Screens ====
import 'package:planmate/Navigation/presentation/navigation_screen.dart';
import 'package:planmate/Onboarding/Presentation/onboarding_screen.dart';
import 'package:planmate/Auth/presentation/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. เรียกใช้ Service เพื่อตั้งค่า Notification (แก้ไขตรงนี้)
  await NotificationService().init(); 

  // บรรทัดสำหรับดึง Token เพื่อดีบั๊ก สามารถลบออกได้แล้ว
  // final token = await FirebaseMessaging.instance.getToken();
  // print("🔑 FCM Token: $token");

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        // 3) ProjectProvider อ่าน repo จาก context
        ChangeNotifierProvider(create: (context) => ProjectProvider()),

        ChangeNotifierProvider<TaskProvider>(
          create: (_) => TaskProvider(),
        ),

        ChangeNotifierProvider<HistoryProvider>(
          create: (_) => HistoryProvider(),
        ),

        ChangeNotifierProvider<HistoryProvider>(
          create: (_) => HistoryProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PlanMate',
        // คุณใช้ธีมเดิมได้เลย; ถ้าอยากใช้ M3 ก็เปลี่ยนเป็น colorSchemeSeed
        theme: ThemeData(
          textTheme: GoogleFonts.interTextTheme(
            Theme.of(context).textTheme,
          ),
          primarySwatch: Colors.purple,
          primaryColor: const Color(0xFF8B5CF6),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            titleTextStyle: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              textStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF8B5CF6),
              textStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color(0xFF8B5CF6), width: 2),
            ),
            labelStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade500,
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

/// ทำ Stateful เพื่อ memoize future ของ onboarding
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late final Future<bool> _seenFuture = _hasSeenOnboarding();

  Future<bool> _hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_onboarding') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // ถ้า AuthProvider มี isLoading จริง ให้ใช้; ถ้าไม่มีก็ตัดบล็อกนี้ออก
        if (authProvider.isLoading) {
          // return Scaffold(
          //   body: Center(
          //     child: CircularProgressIndicator(
          //       valueColor: AlwaysStoppedAnimation<Color>(
          //         Theme.of(context).primaryColor,
          //       ),
          //     ),
          //   ),
          // );
        }

        if (authProvider.isAuthenticated) {
          return const CustomBottomNavBarApp();
        }

        return FutureBuilder<bool>(
          future: _seenFuture, // ✅ ใช้ future เดิม ไม่สร้างใหม่ทุก build
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              );
            }

            if (snap.data == true) {
              return const SignInScreen();
            }
            return const OnboardingScreen();
          },
        );
      },
    );
  }
}
