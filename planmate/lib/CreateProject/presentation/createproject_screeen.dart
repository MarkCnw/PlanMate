import 'package:flutter/material.dart';
import 'package:planmate/CreateProject/Widgets/Appbar/Screen/appbar_screen.dart';
import 'package:planmate/CreateProject/Widgets/Banner/Screen/Banner_screen.dart';
import 'package:planmate/CreateProject/Widgets/Inspiration/inspiration.dart';


class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
