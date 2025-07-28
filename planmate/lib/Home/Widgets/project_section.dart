import 'package:flutter/material.dart';
import 'package:planmate/Home/Widgets/card_widget.dart';
import 'package:planmate/Models/project_model.dart';

class ProjectSection extends StatelessWidget {
  const ProjectSection({super.key});

  @override
  Widget build(BuildContext context) {
    // ใช้ Mock Data ก่อน
    final projects = ProjectModel.getMockProjects();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Our Project',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'See Detail',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Grid View สำหรับ Project Cards
        GridView.builder(
          shrinkWrap: true, // สำคัญ! ให้ Grid ไม่ขยายเต็มหน้าจอ
          physics: const NeverScrollableScrollPhysics(), // ปิดการ scroll ของ Grid
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columns
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2, // อัตราส่วน width:height
          ),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return ProjectCard(project: project);
          },
        ),
      ],
    );
  }
}

