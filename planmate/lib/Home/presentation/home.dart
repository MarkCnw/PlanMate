import 'package:flutter/material.dart';
import 'package:planmate/Home/widgets/Banner/banner.dart';
// import 'package:planmate/Home/Widgets/Banner/progress_widget.dart'; // เอาออก

import 'package:planmate/provider/project_provider.dart';
import 'package:planmate/provider/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:planmate/Home/widgets/Header/header_widget.dart';
import 'package:planmate/Home/widgets/project_section.dart';

// ✅ เพิ่ม import สำหรับ Enhanced Progress Chart
// สมมติว่าเราสร้างไฟล์ enhanced_progress_chart.dart ใน Home/Widgets/Banner/
// และใส่โค้ด EnhancedProgressChartSection ไว้ในนั้น
import 'package:planmate/Home/widgets/Banner/enhanced_progress_chart.dart';

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
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            
            // 🔹 Header Section
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: HeaderSection(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 25)),

            // 🔹 Banner Section
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: BannerHome(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 25)),

            // 🔹 Enhanced Progress Chart (แทนที่ของเก่า)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Consumer2<ProjectProvider, TaskProvider>(
                  builder: (context, projectProvider, taskProvider, _) {
                    // เช็คว่ามี project หรือไม่
                    if (projectProvider.projects.isEmpty && !projectProvider.isInitialLoading) {
                      return _buildEmptyProgressState();
                    }
                    
                    // แสดงกราฟปกติ
                    return const EnhancedProgressChartSection();
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // 🔹 Project Section (ใช้ Provider)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Consumer<ProjectProvider>(
                  builder: (context, projectProvider, _) {
                    return ProjectSection(
                      projectProvider: projectProvider,
                    );
                  },
                ),
              ),
            ),

            // 🔹 Spacer กันไม่ให้ชน BottomNav
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  // ✅ Widget สำหรับแสดงเมื่อไม่มี project
  Widget _buildEmptyProgressState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Progress',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF001858),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Track your daily achievements',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Get Started',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Empty state illustration
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.insights_rounded,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'Create your first project',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start tracking your progress!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Info message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_rounded,
                  size: 20,
                  color: const Color(0xFF8B5CF6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your progress chart will appear here once you create projects and tasks',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF8B5CF6).withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}