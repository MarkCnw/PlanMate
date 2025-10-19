import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planmate/Auth/presentation/terms_acceptance_screen.dart';
import 'package:planmate/History/Provider/history_provider.dart';
import 'package:planmate/provider/task_provider.dart';
import 'package:planmate/Services/notification.dart';
import 'package:planmate/provider/notificationprovider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'package:planmate/provider/auth_provider.dart';
import 'package:planmate/provider/project_provider.dart';
import 'package:planmate/Navigation/presentation/navigation_screen.dart';
import 'package:planmate/Onboarding/Presentation/onboarding_screen.dart';
import 'package:planmate/Auth/presentation/login_screen.dart';

// 🔥 Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('📨 Background message: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale
  await initializeDateFormatting('th', null);
  debugPrint('✅ Thai locale initialized');

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  // Get FCM token
  try {
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint("🔑 FCM Token: $token");
  } catch (e) {
    debugPrint("❌ Failed to get FCM token: $e");
  }

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
        ChangeNotifierProvider(create: (context) => ProjectProvider()),
        ChangeNotifierProvider<TaskProvider>(
          create: (_) => TaskProvider(),
        ),
        ChangeNotifierProvider<HistoryProvider>(
          create: (_) => HistoryProvider(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PlanMate',
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

/// ✅ แก้ไข AuthWrapper ให้ทำงานถูกต้อง
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();

      if (mounted) {
        final notificationProvider = context.read<NotificationProvider>();
        await notificationProvider.initialize();
      }

      debugPrint('✅ All notifications initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize notifications: $e');
    }
  }

  Future<bool> _hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_onboarding') ?? false;
  }

  Future<bool> _hasAcceptedTerms() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_accepted_terms') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ใช้ Consumer เพื่อฟัง auth state แบบ real-time
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        debugPrint('🔄 AuthWrapper rebuild - isAuthenticated: ${authProvider.isAuthenticated}');
        
        // ✅ 1. ถ้า login แล้ว -> ไปหน้าหลัก
        if (authProvider.isAuthenticated) {
          debugPrint('✅ User authenticated, navigating to NavigationScreen');
          return const NavigationScreen();
        }

        // ✅ 2. ถ้ายังไม่ login -> เช็ค Onboarding/Terms
        return FutureBuilder<List<bool>>(
          future: Future.wait([
            _hasSeenOnboarding(),
            _hasAcceptedTerms(),
          ]),
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
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

            final hasSeenOnboarding = snapshot.data?[0] ?? false;
            final hasAcceptedTerms = snapshot.data?[1] ?? false;

            debugPrint('📍 hasSeenOnboarding: $hasSeenOnboarding');
            debugPrint('📍 hasAcceptedTerms: $hasAcceptedTerms');

            // ✅ 3. ยังไม่ accept terms -> แสดงหน้า Terms
            if (!hasAcceptedTerms) {
              return const TermsAcceptanceScreen();
            }

            // ✅ 4. accept แล้วแต่ยังไม่เคยเห็น onboarding -> แสดง Onboarding
            if (!hasSeenOnboarding) {
              return const OnboardingScreen();
            }

            // ✅ 5. accept + เห็น onboarding แล้ว -> แสดงหน้า Login
            return const SignInScreen();
          },
        );
      },
    );
  }
}