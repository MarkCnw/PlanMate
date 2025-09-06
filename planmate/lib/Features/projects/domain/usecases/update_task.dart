// update_task.dart
import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../../../../core/result.dart';

class UpdateTask {
  final TaskRepository repo;
  UpdateTask(this.repo);
  Future<Result<void>> call({
    required String taskId,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
  }) => repo.update(
        taskId: taskId,
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
      );
}
