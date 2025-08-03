import 'package:flutter/material.dart';
import 'package:planmate/Home/Widgets/ProjectSection/project_empty_state.dart';
import 'package:planmate/Home/Widgets/ProjectSection/project_error_state.dart';
import 'package:planmate/Home/Widgets/ProjectSection/project_list_view.dart';
import 'package:planmate/Home/Widgets/ProjectSection/project_loading_state.dart';
import 'package:planmate/Home/Widgets/ProjectSection/project_section_config.dart';
import 'package:planmate/Home/Widgets/ProjectSection/project_section_header.dart';
import 'package:planmate/Home/Widgets/ProjectSection/sized_container_wrapper.dart';
import 'package:planmate/Models/project_model.dart';
import 'package:planmate/CreateProject/presentation/project_screen.dart';

class ProjectSection extends StatelessWidget {
  final AsyncSnapshot<List<ProjectModel>> projectStream;
  final VoidCallback? onSeeDetail;
  final VoidCallback? onCreateProject;
  final VoidCallback? onRetry;

  const ProjectSection({
    super.key,
    required this.projectStream,
    this.onSeeDetail,
    this.onCreateProject,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProjectSectionHeader(onActionTap: onSeeDetail),
        const SizedBox(height: 16),
        _buildContent(context),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    _logStreamState();

    // Loading state
    if (projectStream.connectionState == ConnectionState.waiting) {
      return SizedContainerWrapper(
        height: ProjectSectionConfig.loadingErrorHeight,
        child: const ProjectLoadingState(),
      );
    }

    // Error state
    if (projectStream.hasError) {
      return SizedContainerWrapper(
        height: ProjectSectionConfig.loadingErrorHeight,
        child: ProjectErrorState(
          error: projectStream.error.toString(),
          onRetry: onRetry,
        ),
      );
    }

    // Data state
    if (projectStream.hasData) {
      final projects = projectStream.data!;

      // Empty state
      if (projects.isEmpty) {
        return SizedContainerWrapper(
          height: ProjectSectionConfig.emptyStateHeight,
          child: ProjectEmptyState(onCreateProject: onCreateProject),
        );
      }

      // Projects list
      return SizedContainerWrapper(
        height: ProjectSectionConfig.projectListHeight,
        child: ProjectListView(
          projects: projects,
          onProjectTap: (project) => _handleProjectTap(context, project),
        ),
      );
    }

    // Default loading
    return SizedContainerWrapper(
      height: ProjectSectionConfig.loadingErrorHeight,
      child: const ProjectLoadingState(),
    );
  }

  void _logStreamState() {
    print(
      '🎯 ProjectSection - Connection State: ${projectStream.connectionState}',
    );
    print('🎯 ProjectSection - Has Error: ${projectStream.hasError}');
    print('🎯 ProjectSection - Has Data: ${projectStream.hasData}');

    if (projectStream.hasError) {
      print('❌ ProjectSection Error: ${projectStream.error}');
    }
    if (projectStream.hasData) {
      print('📊 ProjectSection Data Count: ${projectStream.data?.length}');
    }
  }

  void _handleProjectTap(BuildContext context, ProjectModel project) {
    print('🎯 Tapped project: ${project.title}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ShowProjectScreen(
              projectName: project.title,
              iconPath: project.iconPath,
              projectId: project.id,
            ),
      ),
    );
  }
}
