// =====================================================
// features/projects/domain/repositories/task_repository.dart
// =====================================================

import '../entities/task.dart';
import '../../../../../core/result.dart';

abstract class TaskRepository {
  Future<Result<String>> create(Task task);
  Stream<Result<List<Task>>> watchByProject(String projectId);
  Future<Result<void>> toggleComplete(String taskId);
  Future<Result<void>> update({
    required String taskId,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
  });
  Future<Result<void>> delete(String taskId);
  Future<Result<void>> deleteAllInProject(String projectId);
  Future<Result<Map<String, int>>> stats(String projectId);
}
