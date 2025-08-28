import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ⬇️ เปลี่ยน import ให้ชี้ไปยังหน้าเต็มจอของคุณ
// NOTE: ถ้าไฟล์คุณอยู่ path อื่น ให้แก้เป็น path ที่ถูกต้อง

import 'package:planmate/CreateProject/Create/presentation/create_project_screen.dart';

class BannerScreen extends StatefulWidget {
  const BannerScreen({super.key});

  @override
  State<BannerScreen> createState() => _BannerScreenState();
}

class _BannerScreenState extends State<BannerScreen> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF232946),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF667EEA).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Create',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF667EEA),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'What would you\nlike to create\ntoday?',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFfffffe),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 13),
                        const Text(
                          'Start your creative journey with our tools',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFb8c1ec),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: -20,
                  top: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 205, 81, 39).withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: SvgPicture.asset(
                      'assets/avatar/create.svg',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ปุ่ม -> เปิดหน้าเต็มจอ CreateProjectPage
          AnimatedScale(
            curve: Curves.easeOut,
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: GestureDetector(
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                onTap: () {
                  // ⬇️ เปลี่ยนจาก showModalBottomSheet เป็น Navigator.push
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateProjectSheet(),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFeebbc3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.penToSquare,
                        size: 20,
                        color: Color(0xFF121629),
                      ),
                      SizedBox(width: 20),
                      Text(
                        'Create Project',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: Color(0xFF232946),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
