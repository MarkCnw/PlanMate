import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:planmate/Home/Widgets/ProjectSection/project_section_config.dart';
import 'package:planmate/gen/assets.gen.dart';

class ProjectEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onCreateProject;

  const ProjectEmptyState({
    super.key,
    this.title = 'No projects yet',
    this.subtitle = 'Create your first project!',
    this.onCreateProject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height *
          ProjectSectionConfig.emptyStateContainerHeightFactor,
      width: double.infinity,
      padding: ProjectSectionConfig.emptyStatePadding,
      decoration: BoxDecoration(
        // 🆕 Gradient Background (ตาม trend)
        // gradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [Colors.white, Colors.grey.shade50],
        // ),
        borderRadius: BorderRadius.circular(20), // 🆕 เพิ่มความโค้งมน
        // 🆕 Modern Shadow (neumorphism trend)
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.shade200,
        //     offset: const Offset(8, 8),
        //     blurRadius: 20,
        //     spreadRadius: 0,
        //   ),
        //   BoxShadow(
        //     color: Colors.white,
        //     offset: const Offset(-8, -8),
        //     blurRadius: 20,
        //     spreadRadius: 0,
        //   ),
        // ],
        // เอา border ออก (minimalist trend)
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 2,
              child: SvgPicture.asset(
                Assets.avatar.noProject,
                height: ProjectSectionConfig.emptyStateSvgHeight,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF001858),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Color(0xFF172c66)),
            ),
            if (onCreateProject != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onCreateProject,
                child: const Text('Create Project'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
