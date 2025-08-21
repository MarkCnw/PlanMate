import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:planmate/CreateProject/Update/Presentation/update_project_screen.dart';
import 'package:planmate/Models/project_model.dart';

class ProjectScreenDetail extends StatefulWidget {
  final ProjectModel project;

  const ProjectScreenDetail({super.key, required this.project});

  @override
  State<ProjectScreenDetail> createState() => _ProjectScreenDetailState();
}

class _ProjectScreenDetailState extends State<ProjectScreenDetail> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get projectRef => _firestore.collection('projects');

  bool _isDeleting = false;
  late ProjectModel currentProject;

  @override
  void initState() {
    super.initState();
    currentProject = widget.project;
  }

  Future<void> deleteProject(String projectId) async {
    try {
      print('Deleting your project $projectId');
      await projectRef.doc(projectId).delete();
      print('✅ Project deleted successfully');
    } catch (e) {
      print('❌ Failed to delete project: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf9f4ef),
      appBar: _buildAppBar(),
      body: StreamBuilder<DocumentSnapshot>(
        stream: projectRef.doc(widget.project.id).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text('Error loading project: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              currentProject == widget.project) {
            return const Center(child: CircularProgressIndicator());
          }

          // 🔥 แก้ปัญหาที่ 1: อัพเดท currentProject ด้วยข้อมูลใหม่จาก Firestore
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;

            // แปลง Timestamp เป็น milliseconds
            final fixedData = Map<String, dynamic>.from(data);
            if (fixedData['createdAt'] is Timestamp) {
              fixedData['createdAt'] =
                  (fixedData['createdAt'] as Timestamp)
                      .millisecondsSinceEpoch;
            }
            if (fixedData['updatedAt'] is Timestamp) {
              fixedData['updatedAt'] =
                  (fixedData['updatedAt'] as Timestamp)
                      .millisecondsSinceEpoch;
            }

            // อัพเดท currentProject ด้วยข้อมูลใหม่
            currentProject = ProjectModel.fromMap(
              fixedData,
              snapshot.data!.id,
            );
          } else if (snapshot.hasData && !snapshot.data!.exists) {
            // Project ถูกลบแล้ว - แต่ไม่ต้องทำอะไรเพราะ delete confirmation จัดการแล้ว
            return const SizedBox();
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProjectHeader(),
                const SizedBox(height: 20),
                _buildTaskSectionWithoutButton(), // แยกปุ่มออก
                const SizedBox(
                  height: 80,
                ), // เผื่อพื้นที่สำหรับ FloatingActionButton
              ],
            ),
          );
        },
      ),
      floatingActionButton: SizedBox(
        width: 300, // 👈 กำหนดความกว้างเอง
        height: 55, // 👈 เพิ่มความสูงได้ด้วย
        child: FloatingActionButton.extended(
          onPressed: () => _showAddTaskBottomSheet(),
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          label: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Add New Task',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  
                ),
              ),
              SizedBox(width: 8),
              Icon(FontAwesomeIcons.pen, size: 18, color: Colors.white),
            ],
          ),
        ),
      ),

      // 📍 ตำแหน่งปุ่มลอย
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
      // centerFloat = กลางหน้าจอ ด้านล่าง ลอยขึ้นมาจากขอบ
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFFf9f4ef),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Project Details',
        style: TextStyle(
          color: Color(0xFF001858),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
          onPressed: () {
            _showProjectOptions();
          },
        ),
      ],
    );
  }

  Widget _buildProjectHeader() {
    return Container(
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
        boxShadow: [
          BoxShadow(
            color: currentProject.color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset(
              currentProject.iconPath,
              width: 60,
              height: 60,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.white,
                    size: 30,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          Text(
            currentProject.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [const SizedBox(width: 12)],
          ),
        ],
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

  Widget _buildTaskSectionWithoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoChip(_getTimeAgoText(), FontAwesomeIcons.clock),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Total ${currentProject.taskCount} Tasks',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (currentProject.taskCount == 0)
            _buildEmptyTaskStateWithoutButton(),
        ],
      ),
    );
  }

  Widget _buildEmptyTaskStateWithoutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Lottie.asset(
            'assets/lottie/hero.json',
            width: 250,
            height: 250,
            repeat: true,
            animate: true,
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF001858),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first task\nto this project',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF172c66)),
          ),
        ],
      ),
    );
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

  void _showAddTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add New Task',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Task name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task feature coming soon!'),
                        ),
                      );
                    },
                    child: const Text('Add Task'),
                  ),
                ),
              ],
            ),
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
                              Text('Deleting project...'),
                            ],
                          )
                          : Text(
                            'Are you sure you want to delete "${currentProject.title}"?\n\nThis action cannot be undone.',
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
                                try {
                                  await deleteProject(currentProject.id);

                                  if (mounted) {
                                    // 🔥 ปิด dialog ก่อน แล้วให้ StreamBuilder จัดการ navigation
                                    Navigator.of(
                                      context,
                                    ).pop(); // close dialog
                                    Navigator.of(
                                      context,
                                    ).pop(); // close screen

                                    // แสดง SnackBar หลังจาก navigate แล้ว
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
                                              'Project deleted successfully',
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
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    Navigator.of(
                                      context,
                                    ).pop(); // close dialog only
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
                                                'Failed to delete project: $e',
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
                                } finally {
                                  setState(() => _isDeleting = false);
                                }
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
