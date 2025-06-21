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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: isSelected 
                ? Border.all(color: Colors.white, width: 4)
                : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              imagePath,
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 8),
          // ใส่พื้นหลังให้กับข้อความเพื่อให้ชัดเจน
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              // เพิ่มเงาเล็กน้อยเพื่อให้ดูโดดเด่น
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
                fontSize: 16,
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