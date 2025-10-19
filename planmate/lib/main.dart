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
import 'package:intl/date_symbol_data_local.dart'; // 🔥 เพิ่มบรรทัดนี้

import 'firebase_options.dart';

// ==== Layers ====
import 'package:planmate/provider/auth_provider.dart';
import 'package:planmate/provider/project_provider.dart';

// ==== Screens ====
import 'package:planmate/Navigation/presentation/navigation_screen.dart';
import 'package:planmate/Onboarding/Presentation/onboarding_screen.dart';
import 'package:planmate/Auth/presentation/login_screen.dart';

// 🔥 Background message handler (must be top-level function)
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

  // 🔥 Initialize locale data สำหรับภาษาไทย (เพิ่มบรรทัดนี้)
  await initializeDateFormatting('th', null);
  debugPrint('✅ Thai locale initialized');

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔥 Set background message handler
  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  // 🔥 Get FCM token for debugging
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
        // 🔥 เพิ่ม NotificationProvider
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

/// AuthWrapper with notification initialization
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late final Future<bool> _seenFuture = _hasSeenOnboarding();

  @override
  void initState() {
    super.initState();
    // 🔥 Initialize notifications when app starts
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      // ✅ เรียก initialize ทั้ง NotificationService และ Provider
      final notificationService = NotificationService();
      await notificationService.initialize();

      // ✅ จากนั้นค่อย initialize Provider
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
    debugPrint(
      '✅ hasAcceptedTerms: ${prefs.getBool('has_accepted_terms')}',
    );
    return prefs.getBool('has_accepted_terms') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          // 🔥 แก้ตรงนี้ - เปลี่ยนเป็น NavigationScreen
          return const NavigationScreen();
        }

        return FutureBuilder(
          future: Future.wait([_hasSeenOnboarding(), _hasAcceptedTerms()]),
          builder: (context, AsyncSnapshot<List<bool>> snap) {
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

            final hasSeenOnboarding = snap.data?[0] ?? false;
            final hasAcceptedTerms = snap.data?[1] ?? false;

            if (!hasAcceptedTerms) {
              // 🔥 เปิดหน้า TermsAcceptance ก่อน
              return const TermsAcceptanceScreen();
            }

            if (hasSeenOnboarding) {
              return const SignInScreen();
            } else {
              return const OnboardingScreen();
            }
          },
        );
      },
    );
  }
}
