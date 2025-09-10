import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:planmate/CreateProject/Create/presentation/create_task_screen.dart';
import 'package:planmate/CreateProject/widget/task_list_view.dart';
import 'package:planmate/provider/project_provider.dart';
import 'package:planmate/provider/task_provider.dart'; // ✅ เพิ่ม
import 'package:provider/provider.dart';
import 'package:planmate/CreateProject/Update/Presentation/update_project_screen.dart';
import 'package:planmate/Models/project_model.dart';

class ProjectScreenDetail extends StatefulWidget {
  final ProjectModel project;

  const ProjectScreenDetail({super.key, required this.project});

  @override
  State<ProjectScreenDetail> createState() => _ProjectScreenDetailState();
}

class _ProjectScreenDetailState extends State<ProjectScreenDetail> {
  bool _isDeleting = false;
  late ProjectModel currentProject;
  String? _loadingTaskId; // Track which task is being updated
  final ValueNotifier<String?> _loadingTaskIdVN = ValueNotifier<String?>(
    null,
  );

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
  void dispose() {
    // ✅ หยุดฟัง tasks เมื่อออกจากหน้า
    context.read<TaskProvider>().stopListeningToProject(widget.project.id);
    _loadingTaskIdVN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf9f4ef),

      body: SafeArea(
        child: Consumer<ProjectProvider>(
          builder: (context, projectProvider, child) {
            // Find current project from provider
            final project = projectProvider.getProjectById(
              widget.project.id,
            );

            // If project not found (deleted), show empty or navigate back
            if (project == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.folder_off,
                      color: Colors.grey,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text('Project not found'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }

            // Update current project with latest data
            currentProject = project;

            return NestedScrollView(
              headerSliverBuilder:
                  (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(child: _buildProjectHeader()),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
              body:
                  _buildTaskSection(), // ยังเป็นลิสต์เดิม เลื่อนได้ตามปกติ
            );
          },
        ),
      ),

      floatingActionButton: SizedBox(
        width: 300,
        height: 55,
        child: FloatingActionButton.extended(
          onPressed:
              () => _showAddTaskBottomSheet(), // ✅ เปลี่ยนเป็น add task
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          label: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Add New Task',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8),
              Icon(FontAwesomeIcons.plus, size: 18, color: Colors.white),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildProjectHeader() {
    return Container(
      height: 230,
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            currentProject.color.withOpacity(0.8),
            currentProject.color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // ปุ่มลอยมุมซ้าย/ขวา (ไม่กิน layout height)
          Positioned(
            left: 0,
            top: 0,
            child: _circleBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: _circleBtn(
              icon: Icons.more_vert,
              onTap: _showProjectOptions,
            ),
          ),

          // เนื้อหาหลักจัดกลาง
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ), // เผื่อข้างเล็กน้อย
              child: Column(
                mainAxisSize:
                    MainAxisSize
                        .max, // ให้คอลัมน์กินความสูงทั้งหมดของการ์ด
                children: [
                  // รูปจะยืด/หดตามพื้นที่ที่เหลือ
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        currentProject.iconPath,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (_, __, ___) => const Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                              size: 48,
                            ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // บีบข้อความลงถ้าพื้นที่ไม่พอ
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      currentProject.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // const SizedBox(height: 10),

                  // Chips บีบลงถ้าพื้นที่แคบ
                  // FittedBox(
                  //   fit: BoxFit.scaleDown,
                  //   child: Consumer<TaskProvider>(
                  //     builder: (context, tp, _) {
                  //       final s = tp.getProjectTaskStats(
                  //         currentProject.id,
                  //       );
                  //       return Wrap(
                  //         alignment: WrapAlignment.center,
                  //         spacing: 12,
                  //         runSpacing: 8,
                  //         children: [
                  //           _buildInfoChip(
                  //             _getTimeAgoText(),
                  //             FontAwesomeIcons.clock,
                  //           ),
                  //           // _buildInfoChip(
                  //           //   '${s['completed'] ?? 0}/${s['total'] ?? 0} Tasks',
                  //           //   FontAwesomeIcons.listCheck,
                  //           // ),
                  //         ],
                  //       );
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ปุ่มวงกลมโปร่ง ๆ
  Widget _circleBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(.2),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 18),
        onPressed: onTap,
      ),
    );
  }

  // ✅ สร้าง Task Section ใหม่
  Widget _buildTaskSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = taskProvider.getProjectTasks(currentProject.id);
          final isLoading = taskProvider.isProjectLoading(
            currentProject.id,
          );
          final error = taskProvider.error;

          return TaskListView(
            tasks: tasks,
            isLoading: isLoading,
            error: error,
            loadingTaskId: _loadingTaskId,
            onToggleTask: _handleToggleTask,
            onEditTask: _handleEditTask,
            onDeleteTask: _handleDeleteTask,
            onRetry:
                () => taskProvider.refreshProjectTasks(currentProject.id),
          );
        },
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

  // ✅ Task event handlers
  Future<void> _handleToggleTask(String taskId) async {
    setState(() {
      _loadingTaskId = taskId;
    });

    final taskProvider = context.read<TaskProvider>();
    final success = await taskProvider.toggleTaskComplete(taskId);

    setState(() {
      _loadingTaskId = null;
    });

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update task: ${taskProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleEditTask(task) {
    // TODO: Implement edit task functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit task feature coming soon!')),
    );
  }

  Future<void> _handleDeleteTask(String taskId) async {
    final taskProvider = context.read<TaskProvider>();
    final success = await taskProvider.deleteTask(taskId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Task deleted successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete task: ${taskProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showProjectOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.penToSquare,
                    color: Color(0xFF3B82F6),
                  ),
                  title: const Text('Edit Project'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditProjectBottomSheet();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.trash,
                    color: Colors.red,
                  ),
                  title: const Text('Delete Project'),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation();
                  },
                ),
              ],
            ),
          ),
    );
  }

  // ✅ เปลี่ยนจาก mock เป็น real task creation
  void _showAddTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => CreateTaskSheet(
            projectId: currentProject.id,
            projectTitle: currentProject.title,
          ),
    );
  }

  void _showEditProjectBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => UpdateProjectScreen(project: currentProject),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: !_isDeleting,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Delete Project'),
                  content:
                      _isDeleting
                          ? const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Deleting project and all tasks...'),
                            ],
                          )
                          : Text(
                            'Are you sure you want to delete "${currentProject.title}"?\n\nThis will also delete all tasks in this project. This action cannot be undone.',
                          ),
                  actions:
                      _isDeleting
                          ? []
                          : [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                setState(() => _isDeleting = true);

                                // ✅ ลบ tasks ก่อนแล้วค่อยลบ project
                                final taskProvider =
                                    context.read<TaskProvider>();
                                final projectProvider =
                                    context.read<ProjectProvider>();

                                // Delete all tasks first
                                final tasksDeleted = await taskProvider
                                    .deleteAllProjectTasks(
                                      currentProject.id,
                                    );

                                if (tasksDeleted) {
                                  // Then delete project
                                  final projectDeleted =
                                      await projectProvider.deleteProject(
                                        currentProject.id,
                                      );

                                  if (mounted) {
                                    Navigator.of(
                                      context,
                                    ).pop(); // Close dialog

                                    if (projectDeleted) {
                                      Navigator.of(
                                        context,
                                      ).pop(); // Close screen

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Project and all tasks deleted successfully',
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Colors.green,
                                          behavior:
                                              SnackBarBehavior.floating,
                                          margin: EdgeInsets.all(16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(
                                                Icons.error,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  'Failed to delete project: ${projectProvider.error ?? "Unknown error"}',
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Colors.red,
                                          behavior:
                                              SnackBarBehavior.floating,
                                          margin: const EdgeInsets.all(16),
                                          shape:
                                              const RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.all(
                                                      Radius.circular(10),
                                                    ),
                                              ),
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to delete tasks: ${taskProvider.error}',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }

                                setState(() => _isDeleting = false);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                ),
          ),
    );
  }
}
