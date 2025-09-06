// delete_task.dart
import '../repositories/task_repository.dart';
import '../../../../../core/result.dart';

class DeleteTask {
  final TaskRepository repo;
  DeleteTask(this.repo);
  Future<Result<void>> call(String taskId) => repo.delete(taskId);
}