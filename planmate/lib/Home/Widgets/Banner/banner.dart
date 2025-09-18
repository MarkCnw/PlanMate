import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:planmate/Home/Widgets/Banner/text.dart';

// ⬇️ เปลี่ยน import ให้ชี้ไปยังหน้าเต็มจอของคุณ
// NOTE: ถ้าไฟล์คุณอยู่ path อื่น ให้แก้เป็น path ที่ถูกต้อง

class BannerHome extends StatefulWidget {
  const BannerHome({super.key});

  @override
  State<BannerHome> createState() => _BannerHomeState();
}

class _BannerHomeState extends State<BannerHome> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.28,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF232946),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // ข้อความฝั่งซ้าย
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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
                    'Inspirational',

                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF667EEA),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Small Steps, Big Results",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFb8c1ec),
                  ),
                ),
                const StarryText(
                  text: 'Small Steps, Big Results',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 13),
                const Text(
                  "Plan your projects\nachieve your goals",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFb8c1ec),
                  ),
                ),
              ],
            ),
          ),

          // Lottie ฝั่งขวา
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Lottie.asset(
                'assets/lottie/power.json',
                repeat: false,
                animate: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
