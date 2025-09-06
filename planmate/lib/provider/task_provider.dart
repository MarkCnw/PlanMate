import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planmate/History/Models/activity_history_model.dart';

import '../Models/task_model.dart';
import '../Services/firebase_task_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseTaskService _taskService = FirebaseTaskService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // State variables
  Map<String, List<TaskModel>> _projectTasks = {}; // projectId -> tasks
  Map<String, bool> _projectLoading = {}; // projectId -> loading state
  Map<String, StreamSubscription<List<TaskModel>>?> _taskSubscriptions =
      {};
  bool _isOperating = false; // สำหรับ CRUD operations
  String? _error;

  // Getters
  bool get isOperating => _isOperating;
  String? get error => _error;
  String? get currentUserId => _auth.currentUser?.uid;

  // Get tasks for specific project
  List<TaskModel> getProjectTasks(String projectId) {
    return _projectTasks[projectId] ?? [];
  }

  // Get loading state for specific project
  bool isProjectLoading(String projectId) {
    return _projectLoading[projectId] ?? false;
  }

  // Get task statistics for project
  Map<String, int> getProjectTaskStats(String projectId) {
    final tasks = getProjectTasks(projectId);
    final completed = tasks.where((task) => task.isDone).length;
    final pending = tasks.where((task) => !task.isDone).length;
    final overdue = tasks.where((task) => task.isOverdue).length;

    return {
      'total': tasks.length,
      'completed': completed,
      'pending': pending,
      'overdue': overdue,
    };
  }

  // Get specific task by ID
  TaskModel? getTaskById(String taskId) {
    for (final tasks in _projectTasks.values) {
      try {
        return tasks.firstWhere((task) => task.id == taskId);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  // Constructor
  TaskProvider() {
    _initialize();
  }

  // Initialize auth listener
  void _initialize() {
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        _clearAllData();
      }
    });
  }

  // Clear all data when user signs out
  void _clearAllData() {
    for (final subscription in _taskSubscriptions.values) {
      subscription?.cancel();
    }
    _taskSubscriptions.clear();
    _projectTasks.clear();
    _projectLoading.clear();
    _error = null;
    notifyListeners();
    debugPrint('🗑️ Cleared all task data');
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

  // Set operating state
  void _setOperating(bool operating) {
    _isOperating = operating;
    notifyListeners();
  }

  // Start listening to tasks for a specific project
  void startListeningToProject(String projectId) {
    if (currentUserId == null) {
      debugPrint('⚠️ No user logged in, cannot listen to tasks');
      return;
    }

    // Cancel existing subscription if any
    _taskSubscriptions[projectId]?.cancel();

    // Set loading state
    _projectLoading[projectId] = true;
    notifyListeners();

    debugPrint('🔄 Starting to listen to tasks for project: $projectId');

    // Start new subscription
    _taskSubscriptions[projectId] = _taskService
        .getProjectTasks(projectId)
        .listen(
          (List<TaskModel> tasks) {
            _projectTasks[projectId] = tasks;
            _projectLoading[projectId] = false;
            _error = null;
            notifyListeners();
            debugPrint(
              '✅ Received ${tasks.length} tasks for project $projectId',
            );
          },
          onError: (error) {
            debugPrint(
              '❌ Tasks stream error for project $projectId: $error',
            );
            _projectLoading[projectId] = false;
            _setError('Failed to load tasks: $error');
          },
        );
  }

  // Stop listening to tasks for a specific project
  void stopListeningToProject(String projectId) {
    _taskSubscriptions[projectId]?.cancel();
    _taskSubscriptions.remove(projectId);
    _projectTasks.remove(projectId);
    _projectLoading.remove(projectId);
    notifyListeners();
    debugPrint('🛑 Stopped listening to tasks for project: $projectId');
  }

  // Create new task
  Future<String?> createTask({
    required String title,
    required String projectId,
    String? description,
    DateTime? dueDate,
    int priority = 2,
  }) async {
    try {
      debugPrint('🔄 Creating task for project: $projectId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      _setOperating(true);
      clearError();

      final taskId = await _taskService.createTask(
        title: title,
        projectId: projectId,
        description: description,
        dueDate: dueDate,
        priority: priority,
      );

      debugPrint('✅ Task created successfully with ID: $taskId');

      _setOperating(false);
      return taskId;
    } catch (e) {
      debugPrint('❌ Failed to create task: $e');
      _setError('Failed to create task: $e');
      _setOperating(false);
      return null;
    }
  }

  // Toggle task completion (with optimistic updates)
  Future<bool> toggleTaskComplete(String taskId) async {
    try {
      debugPrint('🔄 Toggling task completion: $taskId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Find the task
      TaskModel? task = getTaskById(taskId);
      if (task == null) {
        throw Exception('Task not found');
      }

      // Optimistic update - update UI immediately
      final projectId = task.projectId;
      final tasks = List<TaskModel>.from(_projectTasks[projectId] ?? []);
      final taskIndex = tasks.indexWhere((t) => t.id == taskId);

      if (taskIndex != -1) {
        tasks[taskIndex] = task.toggleComplete();
        _projectTasks[projectId] = tasks;
        notifyListeners();
      }

      // Actual update to Firestore
      await _taskService.toggleTaskComplete(taskId);

      debugPrint('✅ Task completion toggled successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to toggle task: $e');
      _setError('Failed to update task: $e');

      // Revert optimistic update on error
      // The stream will eventually fix the state, but we can be more explicit
      notifyListeners();
      return false;
    }
  }

  // Update task
  Future<bool> updateTask({
    required String taskId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? priority,
  }) async {
    try {
      debugPrint('🔄 Updating task: $taskId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      _setOperating(true);
      clearError();

      await _taskService.updateTask(
        taskId: taskId,
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
      );

      debugPrint('✅ Task updated successfully');

      _setOperating(false);
      return true;
    } catch (e) {
      debugPrint('❌ Failed to update task: $e');
      _setError('Failed to update task: $e');
      _setOperating(false);
      return false;
    }
  }

  // Delete task
  // ใน lib/provider/task_provider.dart
  Future<bool> deleteTask(String taskId) async {
    try {
      debugPrint('🔄 Deleting task: $taskId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      _setOperating(true);
      clearError();

      // ดึงข้อมูล task ก่อนลบ เพื่อใช้ในการบันทึกประวัติ
      final taskSnapshot =
          await FirebaseFirestore.instance
              .collection('tasks')
              .doc(taskId)
              .get();

      if (taskSnapshot.exists) {
        final taskData = taskSnapshot.data()!;

        // ลบ task
        await _taskService.deleteTask(taskId);

        // บันทึกประวัติการลบ (ไม่ใช้ context)
        final activity = ActivityHistoryModel.create(
          type: ActivityType.delete,
          projectId: taskData['projectId'],
          taskId: taskId,
          description: 'ลบงาน: ${taskData['title']}',
          userId: currentUserId,
        );

        // เพิ่มกิจกรรมโดยตรงไปยัง Firestore
        await FirebaseFirestore.instance
            .collection('activities')
            .doc(activity.id)
            .set(activity.toMap());
      }

      debugPrint('✅ Task deleted successfully');
      _setOperating(false);
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete task: $e');
      _setError('Failed to delete task: $e');
      _setOperating(false);
      return false;
    }
  }

  // Delete all tasks for a project (called when project is deleted)
  Future<bool> deleteAllProjectTasks(String projectId) async {
    try {
      debugPrint('🔄 Deleting all tasks for project: $projectId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      _setOperating(true);
      clearError();

      await _taskService.deleteAllProjectTasks(projectId);

      // Clean up local state
      stopListeningToProject(projectId);

      debugPrint('✅ All project tasks deleted successfully');

      _setOperating(false);
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete project tasks: $e');
      _setError('Failed to delete project tasks: $e');
      _setOperating(false);
      return false;
    }
  }

  // Get task statistics from server (for accurate counts)
  Future<Map<String, int>?> getTaskStatsFromServer(
    String projectId,
  ) async {
    try {
      return await _taskService.getTaskStats(projectId);
    } catch (e) {
      debugPrint('❌ Failed to get task stats: $e');
      return null;
    }
  }

  // Refresh tasks for a project
  void refreshProjectTasks(String projectId) {
    debugPrint('🔄 Refreshing tasks for project: $projectId');
    startListeningToProject(projectId);
  }

  // Get tasks filtered by completion status
  List<TaskModel> getFilteredTasks(String projectId, {bool? completed}) {
    final tasks = getProjectTasks(projectId);
    if (completed == null) return tasks;
    return tasks.where((task) => task.isDone == completed).toList();
  }

  // Get overdue tasks for a project
  List<TaskModel> getOverdueTasks(String projectId) {
    return getProjectTasks(
      projectId,
    ).where((task) => task.isOverdue).toList();
  }

  // Get tasks due today for a project
  List<TaskModel> getTasksDueToday(String projectId) {
    return getProjectTasks(
      projectId,
    ).where((task) => task.isDueToday).toList();
  }

  // Get tasks by priority
  List<TaskModel> getTasksByPriority(String projectId, int priority) {
    return getProjectTasks(
      projectId,
    ).where((task) => task.priority == priority).toList();
  }

  // Check if project has any tasks
  bool hasProjectTasks(String projectId) {
    return getProjectTasks(projectId).isNotEmpty;
  }

  // Get completion percentage for project
  double getProjectCompletionRate(String projectId) {
    final tasks = getProjectTasks(projectId);
    if (tasks.isEmpty) return 0.0;

    final completed = tasks.where((task) => task.isDone).length;
    return completed / tasks.length;
  }

  @override
  void dispose() {
    debugPrint('🗑️ Disposing TaskProvider');
    _clearAllData();
    super.dispose();
  }
}
