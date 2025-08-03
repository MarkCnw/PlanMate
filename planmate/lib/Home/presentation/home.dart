import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planmate/Home/Widgets/Header/header_widget.dart';
import 'package:planmate/Home/Widgets/Progress/progress_widget.dart';
import 'package:planmate/Home/Widgets/project_section.dart';

import 'package:planmate/Models/project_model.dart';
import 'package:planmate/Services/firebase_project_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseProjectServices _projectService = FirebaseProjectServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                // Header background
                Container(
                  height: 260,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: HeaderSection(user: user),
                ),

                // Chart section ลอยออกมาด้านล่าง
                Positioned(
                  top: 120,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const ProgressChartSection(),
                  ),
                ),

                // Project section ใช้ Firebase Stream
                Positioned(
                  top: 450,
                  left: 15,
                  right: 15,
                  child: StreamBuilder<List<ProjectModel>>(
                    stream: _projectService.getUserProjectsSimple(),
                    builder: (context, snapshot) {
                      return ProjectSection(
                        projectStream: snapshot,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}