import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planmate/History/Models/activity_history_model.dart';

import '../models/task_model.dart';
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
    final inProgress =
        tasks.where((task) => task.status == TaskStatus.inProgress).length;

    return {
      'total': tasks.length,
      'completed': completed,
      'pending': pending,
      'overdue': overdue,
      'inProgress': inProgress,
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

  /// Helper method to log activity with error handling
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
    }
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

  // ===== Task Creation (Simplified) =====

  /// สร้าง Task แบบง่าย (ไม่มี time estimation)
  Future<String?> createTaskEnhanced({
    required String title,
    required String projectId,
    String? description,
    DateTime? dueDate,
    int priority = 2,
    Duration? estimatedDuration, // เก็บไว้เพื่อ compatibility แต่จะ ignore
    double initialProgress = 0.0,
  }) async {
    try {
      debugPrint('🔄 Creating task for project: $projectId');
      debugPrint(
        '📊 Initial progress: ${(initialProgress * 100).round()}%',
      );

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      _setOperating(true);
      clearError();

      // สร้าง task พื้นฐาน
      final taskId = await _taskService.createTask(
        title: title,
        projectId: projectId,
        description: description,
        dueDate: dueDate,
        priority: priority,
      );

      if (taskId == null) return null;

      // อัปเดต progress หากมี
      if (initialProgress > 0.0) {
        await _taskService.updateTaskProgress(
          taskId: taskId,
          progress: initialProgress,
        );
      }

      // บันทึกประวัติการสร้าง
      await _logActivity(
        type: ActivityType.create,
        projectId: projectId,
        taskId: taskId,
        description: 'สร้างงาน: $title',
        metadata: {
          'priority': priority,
          'initialProgress': initialProgress,
        },
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

  /// สร้าง Task แบบธรรมดา (สำหรับ backward compatibility)
  Future<String?> createTask({
    required String title,
    required String projectId,
    String? description,
    DateTime? dueDate,
    int priority = 2,
  }) async {
    return createTaskEnhanced(
      title: title,
      projectId: projectId,
      description: description,
      dueDate: dueDate,
      priority: priority,
      estimatedDuration: null,
      initialProgress: 0.0,
    );
  }

  // ===== Task Actions (Simplified) =====

  /// Toggle task completion (with optimistic updates)
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
        if (task.isDone) {
          // Mark as not done
          tasks[taskIndex] = task.copyWith(
            isDone: false,
            status:
                task.progress > 0
                    ? TaskStatus.inProgress
                    : TaskStatus.pending,
            completedAt: null,
            updatedAt: DateTime.now(),
          );
        } else {
          // Mark as completed
          tasks[taskIndex] = task.completeTask();
        }
        _projectTasks[projectId] = tasks;
        notifyListeners();
      }

      // Actual update to Firestore
      await _taskService.toggleTaskComplete(taskId);

      // บันทึกประวัติ
      await _logActivity(
        type: ActivityType.complete,
        projectId: projectId,
        taskId: taskId,
        description:
            task.isDone
                ? 'ยกเลิกการทำเสร็จ: ${task.title}'
                : 'ทำงานเสร็จ: ${task.title}',
      );

      debugPrint('✅ Task completion toggled successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to toggle task: $e');
      _setError('Failed to update task: $e');

      // Revert optimistic update on error
      notifyListeners();
      return false;
    }
  }

  /// อัปเดต progress ของ task
  Future<bool> updateTaskProgress({
    required String taskId,
    required double progress,
  }) async {
    try {
      debugPrint(
        '🔄 Updating task progress: $taskId to ${(progress * 100).round()}%',
      );

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Find the task for optimistic update
      TaskModel? task = getTaskById(taskId);
      if (task == null) {
        throw Exception('Task not found');
      }

      // Optimistic update
      final projectId = task.projectId;
      final tasks = List<TaskModel>.from(_projectTasks[projectId] ?? []);
      final taskIndex = tasks.indexWhere((t) => t.id == taskId);

      if (taskIndex != -1) {
        tasks[taskIndex] = task.updateProgress(progress);
        _projectTasks[projectId] = tasks;
        notifyListeners();
      }

      // Actual update to Firestore
      await _taskService.updateTaskProgress(
        taskId: taskId,
        progress: progress,
      );

      // บันทึกประวัติ
      await _logActivity(
        type: ActivityType.update,
        projectId: projectId,
        taskId: taskId,
        description:
            'อัปเดตความคืบหน้า: ${task.title} (${(progress * 100).round()}%)',
        metadata: {'oldProgress': task.progress, 'newProgress': progress},
      );

      debugPrint('✅ Task progress updated successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to update task progress: $e');
      _setError('Failed to update task progress: $e');

      // Revert optimistic update
      notifyListeners();
      return false;
    }
  }

  /// อัปเดต task ทั่วไป
  Future<bool> updateTask({
    required String taskId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? priority,
    Duration? estimatedDuration, // จะถูก ignore
    double? progress, required projectId,
  }) async {
    try {
      debugPrint('🔄 Updating task: $taskId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      _setOperating(true);
      clearError();

      // Find the task for logging
      TaskModel? task = getTaskById(taskId);
      final projectId = task?.projectId ?? '';

      await _taskService.updateTask(
        taskId: taskId,
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        progress: progress,
      );

      // บันทึกประวัติ
      if (task != null) {
        final changes = <String>[];
        if (title != null && title != task.title) changes.add('ชื่อ');
        if (description != null && description != task.description)
          changes.add('รายละเอียด');
        if (priority != null && priority != task.priority)
          changes.add('ความสำคัญ');
        if (progress != null && progress != task.progress)
          changes.add('ความคืบหน้า');

        await _logActivity(
          type: ActivityType.update,
          projectId: projectId,
          taskId: taskId,
          description: 'แก้ไขงาน: ${task.title}',
          metadata: {
            'changedFields': changes,
            'oldTitle': task.title,
            'newTitle': title,
          },
        );
      }

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

  /// ลบ task
  Future<bool> deleteTask(String taskId) async {
    try {
      debugPrint('🔄 Deleting task: $taskId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      _setOperating(true);
      clearError();

      // ดึงข้อมูล task ก่อนลบ เพื่อใช้ในการบันทึกประวัติ
      final task = getTaskById(taskId);
      final projectId = task?.projectId ?? '';
      final taskTitle = task?.title ?? 'ไม่ทราบชื่อ';

      // ลบ task
      await _taskService.deleteTask(taskId);

      // บันทึกประวัติการลบ
      await _logActivity(
        type: ActivityType.delete,
        projectId: projectId,
        taskId: taskId,
        description: 'ลบงาน: $taskTitle',
        metadata: {
          'deletedTitle': taskTitle,
          'deletedAt': DateTime.now().toIso8601String(),
        },
      );

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

  /// ลบ tasks ทั้งหมดของ project
  Future<bool> deleteAllProjectTasks(String projectId) async {
    try {
      debugPrint('🔄 Deleting all tasks for project: $projectId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      _setOperating(true);
      clearError();

      final taskCount = getProjectTasks(projectId).length;
      await _taskService.deleteAllProjectTasks(projectId);

      // Clean up local state
      stopListeningToProject(projectId);

      // บันทึกประวัติ
      await _logActivity(
        type: ActivityType.delete,
        projectId: projectId,
        description: 'ลบงานทั้งหมดในโปรเจค ($taskCount งาน)',
        metadata: {
          'deletedTaskCount': taskCount,
          'deletedAt': DateTime.now().toIso8601String(),
        },
      );

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

  // ===== Data Fetching & Analysis =====

  /// Get task statistics from server
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

  /// Refresh tasks for a project
  void refreshProjectTasks(String projectId) {
    debugPrint('🔄 Refreshing tasks for project: $projectId');
    startListeningToProject(projectId);
  }

  /// Get tasks filtered by completion status
  List<TaskModel> getFilteredTasks(String projectId, {bool? completed}) {
    final tasks = getProjectTasks(projectId);
    if (completed == null) return tasks;
    return tasks.where((task) => task.isDone == completed).toList();
  }

  /// Get overdue tasks for a project
  List<TaskModel> getOverdueTasks(String projectId) {
    return getProjectTasks(
      projectId,
    ).where((task) => task.isOverdue).toList();
  }

  /// Get tasks due today for a project
  List<TaskModel> getTasksDueToday(String projectId) {
    return getProjectTasks(
      projectId,
    ).where((task) => task.isDueToday).toList();
  }

  /// Get tasks by priority
  List<TaskModel> getTasksByPriority(String projectId, int priority) {
    return getProjectTasks(
      projectId,
    ).where((task) => task.priority == priority).toList();
  }

  /// Get tasks by status
  List<TaskModel> getTasksByStatus(String projectId, TaskStatus status) {
    return getProjectTasks(
      projectId,
    ).where((task) => task.status == status).toList();
  }

  /// Check if project has any tasks
  bool hasProjectTasks(String projectId) {
    return getProjectTasks(projectId).isNotEmpty;
  }

  /// Get completion percentage for project
  double getProjectCompletionRate(String projectId) {
    final tasks = getProjectTasks(projectId);
    if (tasks.isEmpty) return 0.0;

    final completed = tasks.where((task) => task.isDone).length;
    return completed / tasks.length;
  }

  /// Get average progress for project (considering all tasks)
  double getProjectAverageProgress(String projectId) {
    final tasks = getProjectTasks(projectId);
    if (tasks.isEmpty) return 0.0;

    final totalProgress = tasks.fold<double>(
      0.0,
      (sum, task) => sum + task.progress,
    );
    return totalProgress / tasks.length;
  }

  /// Search tasks within a project
  List<TaskModel> searchProjectTasks(String projectId, String query) {
    if (query.trim().isEmpty) {
      return getProjectTasks(projectId);
    }

    final searchQuery = query.toLowerCase().trim();
    return getProjectTasks(projectId).where((task) {
      return task.title.toLowerCase().contains(searchQuery) ||
          (task.hasDescription &&
              task.description!.toLowerCase().contains(searchQuery));
    }).toList();
  }

  /// Get tasks summary for multiple projects
  Map<String, Map<String, int>> getMultiProjectTasksSummary(
    List<String> projectIds,
  ) {
    final summary = <String, Map<String, int>>{};

    for (final projectId in projectIds) {
      summary[projectId] = getProjectTaskStats(projectId);
    }

    return summary;
  }

  @override
  void dispose() {
    debugPrint('🗑️ Disposing TaskProvider');
    _clearAllData();
    super.dispose();
  }
}
