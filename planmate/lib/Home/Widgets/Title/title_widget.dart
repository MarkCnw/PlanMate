import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text("Organize Your\nTasks Efficiently",style: TextStyle(fontSize: 30,color: Color(0xFF001858),fontWeight: FontWeight.bold),);
  }
}