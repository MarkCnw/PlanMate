import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:planmate/Home/Widgets/card_widget.dart';
import 'package:planmate/Models/project_model.dart';
import 'package:planmate/CreateProject/presentation/project_screen.dart';

class ProjectSection extends StatelessWidget {
  final AsyncSnapshot<List<ProjectModel>> projectStream;

  const ProjectSection({
    super.key,
    required this.projectStream,
  });

  @override
  Widget build(BuildContext context) {
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

        // Content based on stream state
        SizedBox(
          height: 250,
          child: _buildProjectContent(context),
        ),
      ],
    );
  }

  Widget _buildProjectContent(BuildContext context) {
    print('🎯 ProjectSection - Connection State: ${projectStream.connectionState}');
    print('🎯 ProjectSection - Has Error: ${projectStream.hasError}');
    print('🎯 ProjectSection - Has Data: ${projectStream.hasData}');
    
    if (projectStream.hasError) {
      print('❌ ProjectSection Error: ${projectStream.error}');
    }
    
    if (projectStream.hasData) {
      print('📊 ProjectSection Data Count: ${projectStream.data?.length}');
    }

    // Loading state
    if (projectStream.connectionState == ConnectionState.waiting) {
      return _buildLoadingState(context);
    }

    // Error state - แสดงข้อมูล error ที่แท้จริง
    if (projectStream.hasError) {
      return _buildErrorState(projectStream.error.toString());
    }

    // Data state
    if (projectStream.hasData) {
      final projects = projectStream.data!;
      
      // Empty state
      if (projects.isEmpty) {
        return _buildEmptyState(context);
      }

      // Projects list - ได้ข้อมูลแล้ว
      return _buildProjectsList(context, projects);
    }

    // Default loading state
    return _buildLoadingState(context);
  }

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
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade400,
              size: 32,
            ),
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
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset('assets/avatar/noproject.svg',width: 50,height: 50,)
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
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsList(BuildContext context, List<ProjectModel> projects) {
    print('🎯 Building projects list with ${projects.length} projects');
    
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: projects.length,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemBuilder: (context, index) {
        final project = projects[index];
        print('🎯 Rendering project: ${project.title} - ${project.iconPath}');
        
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 2 - 32,
            child: ProjectCard(
              project: project,
              onTap: () {
                print('🎯 Tapped project: ${project.title}');
                // Navigate to project details
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
              },
            ),
          ),
        );
      },
    );
  }
}