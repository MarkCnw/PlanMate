import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:planmate/Auth/presentation/login_screen.dart';
import 'package:planmate/theme/app_theme.dart';
import 'package:planmate/widgets/botttom_widget.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _markOnboardingAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOnboarding,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Center(
                    child: Lottie.asset(
                      'assets/lottie/power.json',
                      width: 500,
                      height: 500,
                      repeat: true,
                      animate: true,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Easiest Way to\nManage Your Plan',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.chakraPetch(
                          fontSize: 37,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Organized all your task in list and\nproject to help you build new habits',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      CustomButton(
                        onPressed: () async {
                          // บันทึกว่าเคยเห็น Onboarding แล้ว
                          await _markOnboardingAsSeen();

                          // นำทางไปหน้า Login
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignInScreen(),
                              ),
                            );
                          }
                        },
                        swordSize: 80,
                        widthButton: 100,
                        heightButton: 100,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
