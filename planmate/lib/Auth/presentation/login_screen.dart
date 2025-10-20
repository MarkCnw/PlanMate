import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:planmate/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  Future<void> _handleGoogleSignIn() async {
    final auth = context.read<AuthProvider>();

    debugPrint('🔵 [LOGIN] Starting sign in process...');
    debugPrint(
      '🔵 [LOGIN] Before sign in - isAuthenticated: ${auth.isAuthenticated}',
    );

    final success = await auth.signInWithGoogle();

    debugPrint('🔵 [LOGIN] Sign in completed - success: $success');
    debugPrint(
      '🔵 [LOGIN] After sign in - isAuthenticated: ${auth.isAuthenticated}',
    );
    debugPrint('🔵 [LOGIN] Current user: ${auth.currentUser?.uid}');

    if (!success && mounted) {
      final msg = auth.error ?? 'Sign in failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
      auth.clearError();
    } else if (success) {
      debugPrint(
        '✅ [LOGIN] Sign in successful! Waiting for navigation...',
      );
      // ✅ รอให้ AuthWrapper rebuild และ navigate
      await Future.delayed(const Duration(milliseconds: 200));
      debugPrint('🔵 [LOGIN] Should navigate to home now');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf9f4ef),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                "Let's Sign You in",
                textAlign: TextAlign.center,
                style: GoogleFonts.chakraPetch(
                  fontSize: 37,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF001858),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "What's on your\nPlanMate today?",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 20,
                  color: Color(0xFF172c66),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: Lottie.asset(
                  'assets/lottie/3.json',
                  width: 500,
                  height: 500,
                  repeat: true,
                  animate: true,
                ),
              ),

              const SizedBox(height: 40),

              // ปุ่ม Sign in
              Selector<AuthProvider, bool>(
                selector: (_, p) => p.isLoading,
                builder: (context, isLoading, _) {
                  return Center(
                    child: SizedBox(
                      width: 330,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleGoogleSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isLoading ? Colors.grey : Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child:
                            isLoading
                                ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Signing In...",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                                : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/icons/google.png',
                                      scale: 3,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "Sign in with Google",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                  );
                },
              ),

              // แสดง error
              Selector<AuthProvider, String?>(
                selector: (_, p) => p.error,
                builder: (context, error, _) {
                  if (error == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        error,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
