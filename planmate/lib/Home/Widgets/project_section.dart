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
        
        // Horizontal ListView สำหรับ Project Cards
        SizedBox(
          height: 166, // ความสูงของ card (200 / 1.2 = 166)
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // เลื่อนในแนวนอน
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return Container(
                width: 166, // กำหนดความกว้างเท่ากับความสูง (สี่เหลี่ยมจัตุรัส)
                margin: EdgeInsets.only(
                  right: index < projects.length - 1 ? 12 : 0, // เว้นระยะห่างระหว่าง card
                ),
                child: ProjectCard(project: project),
              );
            },
          ),
        ),
      ],
    );
  }
}