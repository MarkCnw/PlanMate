import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:planmate/Models/project_model.dart';
import 'package:planmate/provider/task_provider.dart';
import 'package:provider/provider.dart';

class ProjectCard extends StatefulWidget {
  final ProjectModel project;
  final VoidCallback? onTap;

  const ProjectCard({super.key, required this.project, this.onTap});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  late ProjectModel currentProject;

  @override
  void initState() {
    super.initState();
    currentProject = widget.project;
    // ✅ เริ่มฟัง tasks ของ project นี้
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().startListeningToProject(
        widget.project.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.project.color,
          // gradient: LinearGradient(
          //   colors: [project.color.withOpacity(0.8), project.color],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            // BoxShadow(
            //   color: project.color.withOpacity(0.3),
            //   blurRadius: 8,
            //   offset: const Offset(0, 4),
            // ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon ด้านขวาบน
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(), // Spacer
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    widget.project.iconPath,
                    width: 60,
                    height: 60,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback icon ถ้าโหลดไม่ได้
                      return Icon(
                        Icons.folder,
                        size: 60,
                        color: Colors.white.withOpacity(0.8),
                      );
                    },
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Title
            Text(
              widget.project.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Task count + Detail button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.project.taskCountText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                Container(
                  child: Consumer<TaskProvider>(
                    builder: (context, tp, _) {
                      return Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _buildInfoChip(
                            _getTimeAgoText(),
                            FontAwesomeIcons.clock,
                          ),
                          // _buildInfoChip(
                          //   '${s['completed'] ?? 0}/${s['total'] ?? 0} Tasks',
                          //   FontAwesomeIcons.listCheck,
                          // ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgoText() {
    final now = DateTime.now();
    final difference = now.difference(currentProject.createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just created';
    }
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFff8ba7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
