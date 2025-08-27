import 'package:flutter/material.dart';
import 'package:planmate/provider/project_provider.dart';
import 'package:provider/provider.dart';
import 'package:planmate/Home/Widgets/Header/header_widget.dart';
import 'package:planmate/Home/Widgets/Progress/progress_widget.dart';
import 'package:planmate/Home/Widgets/project_section.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf9f4ef), 
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // Header background
              Container(
                height: 260,
                decoration: const BoxDecoration(
                  // Gradient can be added back if needed
                ),
                padding: const EdgeInsets.all(20),
                child: const HeaderSection(),
              ),
      
              // Chart section
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
      
              // Project section using ProjectProvider
              Positioned(
                top: 450,
                left: 15,
                right: 15,
                child: Consumer<ProjectProvider>(
                  builder: (context, projectProvider, child) {
                    return ProjectSection(
                      projectProvider: projectProvider,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}