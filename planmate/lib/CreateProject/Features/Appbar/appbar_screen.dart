import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppbarWidget extends StatelessWidget {
  const AppbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Create your Project",
      style: GoogleFonts.chakraPetch(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF001858),
      ),
    );
  }
}
