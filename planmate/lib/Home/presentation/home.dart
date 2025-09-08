import 'package:flutter/material.dart';
import 'package:planmate/Home/Widgets/Banner/banner.dart';
import 'package:planmate/Home/Widgets/Banner/progress_widget.dart';
import 'package:planmate/Home/Widgets/Title/title_widget.dart';
import 'package:planmate/provider/project_provider.dart';
import 'package:provider/provider.dart';
import 'package:planmate/Home/Widgets/Header/header_widget.dart';

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
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: 10)),
            // 🔹 Header Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: const HeaderSection(),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 25)),

            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            //     child: const TitleWidget(),
            //   ),
            // ),

            // 🔹 Progress / Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: BannerHome(),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 25)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: ProgressChartSection(),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 20)),

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
}
