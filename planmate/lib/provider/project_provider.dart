import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planmate/History/Models/activity_history_model.dart';

import 'package:planmate/Models/project_model.dart';

class ProjectProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // State variables
  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _error;
  StreamSubscription<QuerySnapshot>? _projectsSubscription;

  // Getters
  List<ProjectModel> get projects => _projects;
  List<ProjectModel> get allProjects => _projects;
  bool get isLoading => _isLoading;
  bool get isInitialLoading => _isInitialLoading;
  String? get error => _error;
  bool get hasProjects => _projects.isNotEmpty;
  int get projectCount => _projects.length;

  // Collection reference
  CollectionReference get projectRef => _firestore.collection('projects');

  // Current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Constructor
  ProjectProvider() {
    _initialize();
  }

  // Initialize - start listening to auth changes and projects
  void _initialize() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _startListeningToProjects();
      } else {
        _stopListeningToProjects();
        _clearProjects();
      }
    });

    // Start listening if user is already signed in
    if (_auth.currentUser != null) {
      _startListeningToProjects();
    }
  }

  // Start listening to projects real-time
  void _startListeningToProjects() {
    if (currentUserId == null) {
      debugPrint(
        '⚠️ No user logged in, cannot start listening to projects',
      );
      return;
    }

    debugPrint(
      '🔄 Starting to listen to projects for user: $currentUserId',
    );

    _projectsSubscription?.cancel(); // Cancel existing subscription

    _projectsSubscription = projectRef
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .listen(
          (QuerySnapshot snapshot) {
            _handleProjectsSnapshot(snapshot);
          },
          onError: (error) {
            debugPrint('❌ Projects stream error: $error');
            _setError('Failed to load projects: $error');
            _setInitialLoading(false);
          },
        );
  }

  // Stop listening to projects
  void _stopListeningToProjects() {
    _projectsSubscription?.cancel();
    _projectsSubscription = null;
    debugPrint('🛑 Stopped listening to projects');
  }

  // Handle projects snapshot from Firestore
  void _handleProjectsSnapshot(QuerySnapshot snapshot) {
    try {
      debugPrint(
        '📦 Received ${snapshot.docs.length} projects from Firestore',
      );

      final projects =
          snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data() as Map<String, dynamic>;
                  return ProjectModel.fromMap(data, doc.id);
                } catch (e) {
                  debugPrint('❌ Error parsing project ${doc.id}: $e');
                  return null;
                }
              })
              .where((project) => project != null)
              .cast<ProjectModel>()
              .toList();

      // Sort projects by creation date (newest first)
      projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _projects = projects;
      _error = null;
      _setInitialLoading(false);

      debugPrint('✅ Successfully loaded ${projects.length} projects');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error handling projects snapshot: $e');
      _setError('Error processing projects data');
      _setInitialLoading(false);
    }
  }

  // Clear projects (when user signs out)
  void _clearProjects() {
    _projects = [];
    _error = null;
    _isInitialLoading = true;
    notifyListeners();
    debugPrint('🗑️ Cleared projects');
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set initial loading state
  void _setInitialLoading(bool loading) {
    _isInitialLoading = loading;
    notifyListeners();
  }

  // Set error state
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper method to log activity with error handling
  Future<void> _logActivity({
    required ActivityType type,
    required String projectId,
    required String description,
    String? taskId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (currentUserId == null) {
        debugPrint('⚠️ Cannot log activity: No user logged in');
        return;
      }

      final activity = ActivityHistoryModel.create(
        type: type,
        projectId: projectId,
        taskId: taskId,
        description: description,
        metadata: metadata,
        userId: currentUserId,
      );

      await FirebaseFirestore.instance
          .collection('activities')
          .doc(activity.id)
          .set(activity.toMap());

      debugPrint('✅ ${type.displayName} activity logged successfully');
    } catch (historyError) {
      debugPrint(
        '⚠️ Failed to log ${type.displayName} activity: $historyError',
      );
      // ไม่ throw error เพราะการดำเนินการหลักอาจสำเร็จแล้ว
      // แค่การบันทึกประวัติที่ล้มเหลว
    }
  }

  // Create new project
  Future<String?> createProject({
    required String title,
    required String iconKey,
    String? description,
  }) async {
    try {
      debugPrint('🔄 Creating project...');
      debugPrint('📍 User ID: $currentUserId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      _setLoading(true);
      clearError();

      // Create ProjectModel
      final project = ProjectModel.create(
        title: title,
        iconKey: iconKey,
        userId: currentUserId!,
        description: description,
      );

      debugPrint('📋 Project data: ${project.toMap()}');

      // Validate project data
      if (!project.isValid) {
        throw Exception('Invalid project data');
      }

      final titleError = project.validateTitle();
      if (titleError != null) {
        throw Exception(titleError);
      }

      final descriptionError = project.validateDescription();
      if (descriptionError != null) {
        throw Exception(descriptionError);
      }

      // Create document in Firestore
      final docRef = await projectRef.add(project.toMap());

      // บันทึกประวัติการสร้าง
      await _logActivity(
        type: ActivityType.create,
        projectId: docRef.id,
        description: 'สร้างโปรเจค: ${project.title}',
      );

      debugPrint('✅ Project created successfully with ID: ${docRef.id}');

      _setLoading(false);
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Failed to create project: $e');
      _setError('Failed to create project: $e');
      _setLoading(false);
      return null;
    }
  }

  // Update existing project
  Future<bool> updateProject({
    required String projectId,
    required String newTitle,
    required String newIconKey,
  }) async {
    try {
      debugPrint('🔄 Updating project...');
      debugPrint('📍 Project ID: $projectId');
      debugPrint('📍 User ID: $currentUserId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      _setLoading(true);
      clearError();

      // Validation
      final tempProject = ProjectModel.create(
        title: newTitle,
        iconKey: newIconKey,
        userId: currentUserId!,
      );

      final titleError = tempProject.validateTitle();
      if (titleError != null) {
        throw Exception(titleError);
      }

      // Check if project exists and belongs to current user
      final projectDoc = await projectRef.doc(projectId).get();
      if (!projectDoc.exists) {
        throw Exception('Project not found');
      }

      final projectData = projectDoc.data() as Map<String, dynamic>;
      if (projectData['userId'] != currentUserId) {
        throw Exception('Not authorized to update this project');
      }

      // Get icon data for the new icon
      final iconOptions = ProjectModel.getIconOptions();
      final iconData = iconOptions[newIconKey] ?? iconOptions['rocket']!;

      // Update project data
      final updateData = {
        'title': newTitle.trim(),
        'iconKey': newIconKey,
        'iconPath': iconData.iconPath,
        'color': iconData.color.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      debugPrint('📤 Update data: $updateData');

      // อัปเดต project ใน Firestore
      await projectRef.doc(projectId).update(updateData);

      // บันทึกประวัติการแก้ไข
      await _logActivity(
        type: ActivityType.update,
        projectId: projectId,
        description: 'แก้ไขโปรเจค: ${newTitle}',
        metadata: {
          'oldTitle': projectData['title'],
          'newTitle': newTitle,
          'oldIconKey': projectData['iconKey'],
          'newIconKey': newIconKey,
        },
      );

      debugPrint('✅ Project updated successfully');
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('❌ Failed to update project: $e');
      _setError('Failed to update project: $e');
      _setLoading(false);
      return false;
    }
  }

  // Delete project
  Future<bool> deleteProject(String projectId) async {
    try {
      debugPrint('🔄 Deleting project...');
      debugPrint('📍 Project ID: $projectId');
      debugPrint('📍 User ID: $currentUserId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      _setLoading(true);
      clearError();

      // ดึงข้อมูล project ก่อนลบ เพื่อใช้ในการบันทึกประวัติ
      final projectDoc = await projectRef.doc(projectId).get();
      if (!projectDoc.exists) {
        throw Exception('Project not found');
      }

      final projectData = projectDoc.data() as Map<String, dynamic>;
      if (projectData['userId'] != currentUserId) {
        throw Exception('Not authorized to delete this project');
      }

      final projectTitle = projectData['title'] ?? 'ไม่ทราบชื่อ';
      final taskCount = projectData['taskCount'] ?? 0;

      // ลบ project จาก Firestore
      await projectRef.doc(projectId).delete();

      // บันทึกประวัติการลบ
      await _logActivity(
        type: ActivityType.delete,
        projectId: projectId,
        description: 'ลบโปรเจค: $projectTitle',
        metadata: {
          'deletedTitle': projectTitle,
          'taskCount': taskCount,
          'deletedAt': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('✅ Project deleted successfully');
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete project: $e');
      _setError('Failed to delete project: $e');
      _setLoading(false);
      return false;
    }
  }

  // Get project by ID
  ProjectModel? getProjectById(String projectId) {
    try {
      return _projects.firstWhere((project) => project.id == projectId);
    } catch (e) {
      return null;
    }
  }

  // Get projects by icon key
  List<ProjectModel> getProjectsByIcon(String iconKey) {
    return _projects
        .where((project) => project.iconKey == iconKey)
        .toList();
  }

  // Get recent projects (last 5)
  List<ProjectModel> get recentProjects {
    if (_projects.length <= 5) return _projects;
    return _projects.sublist(0, 5);
  }

  // Get project count by status (this can be extended for tasks)
  Map<String, int> get projectStats {
    return {
      'total': _projects.length,
      'withTasks': _projects.where((p) => p.taskCount > 0).length,
      'withoutTasks': _projects.where((p) => p.taskCount == 0).length,
    };
  }

  // Refresh projects manually
  Future<void> refreshProjects() async {
    debugPrint('🔄 Manual refresh projects');
    if (currentUserId != null) {
      _startListeningToProjects();
    }
  }

  // Check connection to Firestore
  Future<bool> checkConnection() async {
    try {
      debugPrint('🔄 Checking Firestore connection...');

      // Try to get a single document to test connection
      await _firestore.collection('test').limit(1).get();

      debugPrint('✅ Firestore connection OK');
      return true;
    } catch (e) {
      debugPrint('❌ Firestore connection failed: $e');
      return false;
    }
  }

  List<ProjectModel> searchProjects(String query) {
    if (query.trim().isEmpty) {
      return _projects;
    }
    final searchQuery = query.toLowerCase().trim();

    return _projects.where((projects) {
      return projects.title.toLowerCase().contains(searchQuery);
    }).toList();
  }

  @override
  void dispose() {
    debugPrint('🗑️ Disposing ProjectProvider');
    _stopListeningToProjects();
    super.dispose();
  }
}
