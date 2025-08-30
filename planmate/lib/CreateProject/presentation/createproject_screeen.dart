import 'package:flutter/material.dart';
import 'package:planmate/CreateProject/Features/Appbar/appbar_screen.dart';
import 'package:planmate/CreateProject/Features/Banner/Banner_screen.dart';
import 'package:planmate/CreateProject/Features/Inspiration/Screen/inspiration.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFFd4d8f0),
      // backgroundColor: Color(0xFFd4d8f0),
      backgroundColor: Color(0xFFf9f4ef), 
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppbarWidget(),
              SizedBox(height: 20),
              BannerScreen(),
              SizedBox(height: 40),
              InspirationSection(),
            ],
          ),
        ),
      ),
    );
  }
}
