import 'package:flutter/material.dart';

class AppbarWidget extends StatelessWidget {
  const AppbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Create your Project",
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 24,
        color: Color(0xFF232946),
      ),
    );
  }
}
