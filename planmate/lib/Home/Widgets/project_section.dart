import 'package:flutter/material.dart';
import 'package:planmate/CreateProject/Create/presentation/create_project_screen.dart';
import 'package:planmate/provider/project_provider.dart';
import 'package:provider/provider.dart';
import 'package:planmate/Home/widgets/ProjectSection/project_empty_state.dart';
import 'package:planmate/Home/widgets/ProjectSection/project_error_state.dart';
import 'package:planmate/Home/widgets/ProjectSection/project_list_view.dart';
import 'package:planmate/Home/widgets/ProjectSection/project_loading_state.dart';
import 'package:planmate/Home/widgets/ProjectSection/project_section_config.dart';
import 'package:planmate/Home/widgets/ProjectSection/project_section_header.dart';
import 'package:planmate/Home/widgets/ProjectSection/sized_container_wrapper.dart';
import 'package:planmate/models/project_model.dart';
import 'package:planmate/CreateProject/Presentation/project_screen.dart';



class ProjectSection extends StatelessWidget {
  final ProjectProvider? projectProvider; // Optional - can use context.watch
  final VoidCallback? onSeeDetail;

  const ProjectSection({
    super.key,
    this.projectProvider,
    this.onSeeDetail,
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
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, child) {
        _logProviderState(projectProvider);

        // Initial loading state
        if (projectProvider.isInitialLoading) {
          return SizedContainerWrapper(
            height: ProjectSectionConfig.loadingErrorHeight,
            child: const ProjectLoadingState(),
          );
        }

        // Error state
        if (projectProvider.error != null) {
          return SizedContainerWrapper(
            height: ProjectSectionConfig.loadingErrorHeight,
            child: ProjectErrorState(
              error: projectProvider.error!,
              onRetry: () => projectProvider.refreshProjects(),
            ),
          );
        }

        final projects = projectProvider.projects;

        // Empty state
        if (projects.isEmpty) {
          return SizedContainerWrapper(
            height: ProjectSectionConfig.emptyStateHeight,
            child: ProjectEmptyState(
              onCreateProject: () => _showCreateProjectSheet(context),
            ),
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
      },
    );
  }

  void _logProviderState(ProjectProvider projectProvider) {
    debugPrint('🎯 ProjectSection - Provider State:');
    debugPrint('   - Initial Loading: ${projectProvider.isInitialLoading}');
    debugPrint('   - Loading: ${projectProvider.isLoading}');
    debugPrint('   - Has Error: ${projectProvider.error != null}');
    debugPrint('   - Project Count: ${projectProvider.projects.length}');

    if (projectProvider.error != null) {
      debugPrint('❌ ProjectSection Error: ${projectProvider.error}');
    }
  }

  void _handleProjectTap(BuildContext context, ProjectModel project) {
    debugPrint('🎯 Tapped project: ${project.title}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectScreenDetail(project: project),
      ),
    );
  }

  void _showCreateProjectSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => const CreateProjectSheet(),
    );
  }
}