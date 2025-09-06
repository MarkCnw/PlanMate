// =====================================================
// features/projects/presentation/controllers/task_controller.dart
// (Provider/ChangeNotifier ตัวอย่าง)
// =====================================================

import 'package:flutter/foundation.dart';
import 'package:planmate/Features/projects/domain/entities/task.dart';
import 'package:planmate/Features/projects/domain/usecases/create_task.dart';
import 'package:planmate/Features/projects/domain/usecases/delete_all_project_tasks.dart';
import 'package:planmate/Features/projects/domain/usecases/delete_task.dart';
import 'package:planmate/Features/projects/domain/usecases/get_task_stats.dart';
import 'package:planmate/Features/projects/domain/usecases/toggle_complete.dart';
import 'package:planmate/Features/projects/domain/usecases/update_task.dart';
import 'package:planmate/Features/projects/domain/usecases/watch_tasks_by_project.dart';
import 'package:planmate/core/result.dart';

class TaskController extends ChangeNotifier {
  final CreateTask _createTask;
  final WatchTasksByProject _watch;
  final ToggleTaskComplete _toggle;
  final UpdateTask _update;
  final DeleteTask _delete;
  final DeleteAllProjectTasks _deleteAll;
  final GetTaskStats _stats;

  TaskController({
    required CreateTask createTask,
    required WatchTasksByProject watch,
    required ToggleTaskComplete toggle,
    required UpdateTask update,
    required DeleteTask delete,
    required DeleteAllProjectTasks deleteAll,
    required GetTaskStats stats,
  }) : _createTask = createTask,
       _watch = watch,
       _toggle = toggle,
       _update = update,
       _delete = delete,
       _deleteAll = deleteAll,
       _stats = stats;

  List<Task> _tasks = [];
  bool _loading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _loading;
  String? get error => _error;

  Stream<Result<List<Task>>> watchByProject(String projectId) {
    return _watch(projectId).map((res) {
      res.when(
        success: (data) {
          _tasks = data;
          _error = null;
          notifyListeners();
        },
        error: (f) {
          _error = f.message;
          notifyListeners();
        },
      );
      return res;
    });
  }

  Future<Result<String>> create(Task task) async {
    _loading = true;
    notifyListeners();
    final res = await _createTask(task);
    res.when(
      success: (_) {
        _error = null;
      },
      error: (f) {
        _error = f.message;
      },
    );
    _loading = false;
    notifyListeners();
    return res;
  }

  Future<Result<void>> toggle(String taskId) async {
    final res = await _toggle(taskId);
    res.when(
      success: (_) {
        _error = null;
      },
      error: (f) {
        _error = f.message;
        notifyListeners();
      },
    );
    return res;
  }

  Future<Result<void>> updateTask({
    required String taskId,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
  }) async {
    final res = await _update(
      taskId: taskId,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
    );
    res.when(
      success: (_) {
        _error = null;
      },
      error: (f) {
        _error = f.message;
        notifyListeners();
      },
    );
    return res;
  }

  Future<Result<void>> delete(String taskId) async {
    final res = await _delete(taskId);
    res.when(
      success: (_) {
        _error = null;
      },
      error: (f) {
        _error = f.message;
        notifyListeners();
      },
    );
    return res;
  }

  Future<Result<void>> deleteAll(String projectId) async {
    final res = await _deleteAll(projectId);
    res.when(
      success: (_) {
        _error = null;
      },
      error: (f) {
        _error = f.message;
        notifyListeners();
      },
    );
    return res;
  }

  Future<Result<Map<String, int>>> stats(String projectId) =>
      _stats(projectId);
}
