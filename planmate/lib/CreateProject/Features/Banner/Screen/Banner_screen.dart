import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      // margin: const EdgeInsets.symmetric(
      //   horizontal: 16,
      //   vertical: 8,
      // ), // 🆕 เพิ่ม margin
      padding: const EdgeInsets.all(20), // 🆕 เพิ่ม padding
      decoration: BoxDecoration(
        color: const Color(0xFF232946),
        //สีเดิม
        // gradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [Colors.white, Colors.grey.shade50],
        // ),
        borderRadius: BorderRadius.circular(20), // 🆕 เพิ่มความโค้งมน
        // 🆕 Modern Shadow (neumorphism trend)
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.shade200,
        //     offset: const Offset(8, 8),
        //     blurRadius: 20,
        //     spreadRadius: 0,
        //   ),
        //   BoxShadow(
        //     color: Colors.white,
        //     offset: const Offset(-8, -8),
        //     blurRadius: 20,
        //     spreadRadius: 0,
        //   ),
        // ],
        // เอา border ออก (minimalist trend)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                // 🆕 เพิ่ม subtitle
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🆕 เพิ่ม category/tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF667EEA,
                            ).withOpacity(0.1),
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
                        // Main title
                        const Text(
                          'What would you\nlike to create\ntoday?',
                          style: TextStyle(
                            fontSize: 22, // 🆕 ปรับขนาดให้เหมาะสม
                            fontWeight: FontWeight.w700, // 🆕 เพิ่มความหนา
                            color: Color(
                              0xFFfffffe,
                            ), // 🆕 สีที่อ่านง่ายขึ้น
                            height: 1.4, // 🆕 เพิ่ม line height
                          ),
                        ),
                        const SizedBox(height: 13),
                        // 🆕 เพิ่ม subtitle
                        Text(
                          'Start your creative journey with our tools',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(
                              0xFFb8c1ec,
                            ), // 🆕 สีที่อ่านง่ายขึ้น
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // รูปภาพทางขวา
                Positioned(
                  right: -20, // 🆕 ปรับตำแหน่งให้ดูธรรมชาติ
                  top: 20,
                  child: Container(
                    // 🆕 เพิ่ม background circle
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        205,
                        81,
                        39,
                      ).withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: SvgPicture.asset(
                      'assets/avatar/create.svg',
                      width: 100, // 🆕 ลดขนาดให้เหมาะสม
                      height: 100,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🆕 ปรับปรุงปุ่มตาม trend พร้อม scale animation
          AnimatedScale(
            curve: Curves.easeOut,
            scale: _isPressed ? 0.95 : 1.0, // หดลง 5% ตอนกด
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: double.infinity,
              height: 56, // 🆕 เพิ่มความสูง
              child: GestureDetector(
                onTapDown: (details) => setState(() => _isPressed = true),
                onTapUp: (details) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder:
                        (context) => CreateProjectSheet(
                          onSubmit: (name, icon) {
                            print("ชื่อโปรเจกต์: $name");
                            print("ไอคอน: $icon");
                            // TODO: บันทึกหรือสร้างโปรเจกต์จริง
                          },
                        ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFeebbc3), // คงสีเดิม
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        FontAwesomeIcons.penToSquare, 
                        size: 20,
                        color: Color(0xFF121629),
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        'Create Project',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5, // 🆕 เพิ่ม letter spacing
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