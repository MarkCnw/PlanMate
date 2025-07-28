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
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: projects.length,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (context, index) {
              final project = projects[index];
              return Padding(
                padding: const EdgeInsets.only(
                  right: 20,
                ), // ระยะห่างระหว่างการ์ด
                child: SizedBox(
                  width:
                      MediaQuery.of(context).size.width / 2 -
                      32, // ✅ ขนาดเท่า Grid 2 คอลัมน์
                  child: ProjectCard(project: project),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
