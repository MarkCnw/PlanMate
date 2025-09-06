// =====================================================
// features/projects/data/repositories/task_repository_impl.dart
// =====================================================

import 'package:planmate/Features/projects/data/datasources/task_remote_ds.dart';
import 'package:planmate/Features/projects/data/models/task_model.dart';

import '../../../../../core/result.dart';
import '../entities/task.dart';
import 'task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _ds;
  TaskRepositoryImpl(this._ds);

  @override
  Future<Result<String>> create(Task task) async {
    try {
      // Domain validation first
      final titleErr = task.validateTitle();
      if (titleErr != null)
        return Error(Failure(titleErr, code: 'title_invalid'));
      final descErr = task.validateDescription();
      if (descErr != null)
        return Error(Failure(descErr, code: 'desc_invalid'));
      if (!task.isValid)
        return Error(Failure('Invalid task data', code: 'invalid'));

      final id = await _ds.create(TaskModel.fromEntity(task));
      return Success(id);
    } catch (e, st) {
      return Error(
        Failure('Create task failed', code: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Stream<Result<List<Task>>> watchByProject(String projectId) {
    return _ds.watchByProject(projectId).map((ms) {
      try {
        final list = ms.map((m) => m.toEntity()).toList();
        return Success<List<Task>>(list);
      } catch (e, st) {
        return Error<List<Task>>(
          Failure(
            'Parse tasks failed',
            code: e.toString(),
            stackTrace: st,
          ),
        );
      }
    });
  }

  @override
  Future<Result<void>> toggleComplete(String taskId) async {
    try {
      await _ds.toggleComplete(taskId);
      return const Success(null);
    } catch (e, st) {
      return Error(
        Failure('Toggle task failed', code: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> update({
    required String taskId,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
  }) async {
    try {
      await _ds.update(
        taskId: taskId,
        title: title,
        description: description,
        dueDate: dueDate,
        priority:
            priority == null
                ? null
                : (priority == TaskPriority.high)
                ? 1
                : (priority == TaskPriority.low)
                ? 3
                : 2,
      );
      return const Success(null);
    } catch (e, st) {
      return Error(
        Failure('Update task failed', code: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> delete(String taskId) async {
    try {
      await _ds.delete(taskId);
      return const Success(null);
    } catch (e, st) {
      return Error(
        Failure('Delete task failed', code: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> deleteAllInProject(String projectId) async {
    try {
      await _ds.deleteAllInProject(projectId);
      return const Success(null);
    } catch (e, st) {
      return Error(
        Failure('Bulk delete failed', code: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<Map<String, int>>> stats(String projectId) async {
    try {
      final m = await _ds.stats(projectId);
      return Success(m);
    } catch (e, st) {
      return Error(
        Failure('Get stats failed', code: e.toString(), stackTrace: st),
      );
    }
  }
}
