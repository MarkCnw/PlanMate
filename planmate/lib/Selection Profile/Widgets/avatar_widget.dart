import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AvatarItem extends StatelessWidget {
  final String imagePath;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const AvatarItem({
    super.key,
    required this.imagePath,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // คำนวณขนาดตามความกว้างหน้าจอ
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarSize =
        (screenWidth - 60) /
        3.5; // 60 = padding ซ้าย-ขวา, 3.5 = พื้นที่สำหรับ 3 avatar + spacing
    final clampedSize = avatarSize.clamp(
      70.0,
      100.0,
    ); // จำกัดขนาดไม่ให้เล็กหรือใหญ่เกินไป

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border:
                  isSelected
                      ? Border.all(color: Colors.white, width: 4)
                      : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              imagePath,
              width: clampedSize,
              height: clampedSize,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              name,
              style: GoogleFonts.chakraPetch(
                fontSize: 14, // ลดขนาดฟอนต์จาก 16 เป็น 14
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Color(0xFFF6874E) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
