import 'package:flutter/material.dart';
import 'package:planmate/Home/Widgets/ProjectSection/project_section_config.dart';
import 'package:planmate/Models/project_model.dart';
import 'package:planmate/Home/Widgets/ProjectSection/project_card_widget.dart';


class ProjectListView extends StatelessWidget {
  final List<ProjectModel> projects;
  final Function(ProjectModel) onProjectTap;

  const ProjectListView({
    super.key,
    required this.projects,
    required this.onProjectTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: projects.length,
      padding: ProjectSectionConfig.projectListPadding,
      itemBuilder: (context, index) {
        final project = projects[index];
        
        return Padding(
          padding: const EdgeInsets.only(
            right: ProjectSectionConfig.cardSpacing,
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 
                ProjectSectionConfig.cardWidth - 32,
            height: ProjectSectionConfig.cardHeight,
            child: ProjectCard(
              project: project,
              onTap: () => onProjectTap(project),
            ),
          ),
        );
      },
    );
  }
}