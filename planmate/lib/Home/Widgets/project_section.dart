import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:planmate/Home/Widgets/HasData/card_widget.dart';
import 'package:planmate/Models/project_model.dart';
import 'package:planmate/CreateProject/presentation/project_screen.dart';
import 'package:planmate/gen/assets.gen.dart';

// ✅ Configuration Constants - แก้ไขง่ายในอนาคต
class _ProjectSectionConfig {
  // Heights
  static const double emptyStateHeight = 250.0;
  static const double projectListHeight = 180.0;
  static const double loadingErrorHeight = 180.0;
  
  // Empty State
  static const double emptyStateSvgHeight = 150.0;
  static const EdgeInsets emptyStatePadding = EdgeInsets.all(20);
  static const double emptyStateContainerHeightFactor = 0.4; // * screen height
  
  // Project List
  static const double cardWidth = 2.0; // screen width / cardWidth - 32
  static const double cardHeight = 160.0; // หรือใช้ aspect ratio
  static const EdgeInsets projectListPadding = EdgeInsets.symmetric(horizontal: 10);
  static const double cardSpacing = 12.0;
  
  // Styling
  static const BorderRadius containerBorderRadius = BorderRadius.all(Radius.circular(20));
  static const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(16));
}

class ProjectSection extends StatelessWidget {
  final AsyncSnapshot<List<ProjectModel>> projectStream;

  const ProjectSection({super.key, required this.projectStream});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildContent(context),
      ],
    );
  }

  // ✅ แยก Header เป็น method ต่างหาก
  Widget _buildHeader() {
    return Row(
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
    );
  }

  // ✅ Main Content Router - แยกความสูงตาม state
  Widget _buildContent(BuildContext context) {
    _logStreamState(); // Debug logging

    // Loading state
    if (projectStream.connectionState == ConnectionState.waiting) {
      return _buildWithHeight(
        height: _ProjectSectionConfig.loadingErrorHeight,
        child: _buildLoadingState(context),
      );
    }

    // Error state
    if (projectStream.hasError) {
      return _buildWithHeight(
        height: _ProjectSectionConfig.loadingErrorHeight,
        child: _buildErrorState(projectStream.error.toString()),
      );
    }

    // Data state
    if (projectStream.hasData) {
      final projects = projectStream.data!;

      // Empty state - ใช้ความสูงพิเศษ
      if (projects.isEmpty) {
        return _buildWithHeight(
          height: _ProjectSectionConfig.emptyStateHeight,
          child: _buildEmptyState(context),
        );
      }

      // Projects list - ใช้ความสูงมาตรฐาน
      return _buildWithHeight(
        height: _ProjectSectionConfig.projectListHeight,
        child: _buildProjectsList(context, projects),
      );
    }

    // Default loading
    return _buildWithHeight(
      height: _ProjectSectionConfig.loadingErrorHeight,
      child: _buildLoadingState(context),
    );
  }

  // ✅ Helper: Wrap with consistent height container
  Widget _buildWithHeight({required double height, required Widget child}) {
    return SizedBox(height: height, child: child);
  }

  // ✅ Debug logging method
  void _logStreamState() {
    print('🎯 ProjectSection - Connection State: ${projectStream.connectionState}');
    print('🎯 ProjectSection - Has Error: ${projectStream.hasError}');
    print('🎯 ProjectSection - Has Data: ${projectStream.hasData}');

    if (projectStream.hasError) {
      print('❌ ProjectSection Error: ${projectStream.error}');
    }
    if (projectStream.hasData) {
      print('📊 ProjectSection Data Count: ${projectStream.data?.length}');
    }
  }

  // ✅ Loading State
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading projects...',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ✅ Error State
  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: _ProjectSectionConfig.containerBorderRadius,
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 32),
            const SizedBox(height: 8),
            Text(
              'Failed to load projects',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: TextStyle(color: Colors.red.shade600, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Empty State - ใช้ config สำหรับทุกค่า
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * _ProjectSectionConfig.emptyStateContainerHeightFactor,
      width: double.infinity,
      padding: _ProjectSectionConfig.emptyStatePadding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF6F0FF), Colors.white],
        ),
        borderRadius: _ProjectSectionConfig.containerBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(8, 8),
            blurRadius: 20,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white,
            offset: const Offset(-8, -8),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 2,
              child: SvgPicture.asset(
                Assets.avatar.noproject,
                height: _ProjectSectionConfig.emptyStateSvgHeight,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No projects yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Create your first project!',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Projects List - ใช้ config สำหรับทุกค่า
  Widget _buildProjectsList(BuildContext context, List<ProjectModel> projects) {
    print('🎯 Building projects list with ${projects.length} projects');

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: projects.length,
      padding: _ProjectSectionConfig.projectListPadding,
      itemBuilder: (context, index) {
        final project = projects[index];
        print('🎯 Rendering project: ${project.title} - ${project.iconPath}');

        return Padding(
          padding: EdgeInsets.only(right: _ProjectSectionConfig.cardSpacing),
          child: SizedBox(
            width: MediaQuery.of(context).size.width / _ProjectSectionConfig.cardWidth - 32,
            height: _ProjectSectionConfig.cardHeight,
            child: ProjectCard(
              project: project,
              onTap: () => _handleProjectTap(context, project),
            ),
          ),
        );
      },
    );
  }

  // ✅ แยก navigation logic
  void _handleProjectTap(BuildContext context, ProjectModel project) {
    print('🎯 Tapped project: ${project.title}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowProjectScreen(
          projectName: project.title,
          iconPath: project.iconPath,
          projectId: project.id,
        ),
      ),
    );
  }
}