import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:planmate/CreateProject/Widgets/inspiration.dart';

import 'package:planmate/CreateProject/presentation/showmodal.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create your Project",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                // margin: const EdgeInsets.symmetric(
                //   horizontal: 16,
                //   vertical: 8,
                // ), // 🆕 เพิ่ม margin
                padding: const EdgeInsets.all(20), // 🆕 เพิ่ม padding
                decoration: BoxDecoration(
                  // 🆕 Gradient Background (ตาม trend)
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.grey.shade50],
                  ),
                  borderRadius: BorderRadius.circular(
                    20,
                  ), // 🆕 เพิ่มความโค้งมน
                  // 🆕 Modern Shadow (neumorphism trend)
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      offset: const Offset(8, 8),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.white,
                      offset: const Offset(-8, -8),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ],
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
                              width:
                                  MediaQuery.of(context).size.width * 0.55,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
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
                                      borderRadius: BorderRadius.circular(
                                        20,
                                      ),
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
                                      fontSize:
                                          22, // 🆕 ปรับขนาดให้เหมาะสม
                                      fontWeight:
                                          FontWeight
                                              .w700, // 🆕 เพิ่มความหนา
                                      color: Color(
                                        0xFF1A202C,
                                      ), // 🆕 สีที่อ่านง่ายขึ้น
                                      height: 1.4, // 🆕 เพิ่ม line height
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // 🆕 เพิ่ม subtitle
                                  Text(
                                    'Start your creative journey with our tools',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade600,
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

                    // 🆕 ปรับปรุงปุ่มตาม trend
                    Container(
                      width: double.infinity,
                      height: 56, // 🆕 เพิ่มความสูง
                      child: ElevatedButton(
                        onPressed: () {
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
                        
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          elevation: 0, // 🆕 เอา shadow ออก (flat design)
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              16,
                            ), // 🆕 เพิ่มความโค้งมน
                          ),
                          // 🆕 เพิ่ม gradient button
                          shadowColor: Colors.transparent,
                        ).copyWith(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>((
                                Set<MaterialState> states,
                              ) {
                                if (states.contains(
                                  MaterialState.pressed,
                                )) {
                                  return const Color(0xFF5A67D8);
                                }
                                return const Color(0xFF667EEA);
                              }),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              FontAwesomeIcons.penToSquare,
                              size: 20,
                            ),
                            const SizedBox(width: 20),
                            const Text(
                              'Create Project',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing:
                                    0.5, // 🆕 เพิ่ม letter spacing
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),
              InspirationSection(),
            ],
          ),
        ),
      ),
    );
  }
}
