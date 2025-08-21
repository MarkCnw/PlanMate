import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:planmate/Auth/services/google_service.dart';
import 'package:planmate/Navigation/presentation/navigation_screen.dart';
import 'package:planmate/Widgets/snackbar.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isLoading = false;

  Future<void> signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseServices().signInWithGoogle();

      // เช็คว่า user ได้เข้าสู่ระบบแล้วหรือไม่
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null && mounted) {
        // นำทางไปหน้า Home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const CustomBottomNavBarApp(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(context, 'Sign in failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf9f4ef),
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
                  color: Color(0xFF001858),
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
                  'assets/lottie/2.json',
                  width: 500,
                  height: 500,
                  repeat: true,
                  animate: true,
                ),
              ),

              const SizedBox(height: 40),

              Center(
                child: SizedBox(
                  width: 330,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : signInWithGoogle,
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Signing In...",
                                  style: GoogleFonts.chakraPetch(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/google.png',
                                  scale: 3,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Sign in with Google",
                                  style: GoogleFonts.chakraPetch(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
