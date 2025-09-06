
// toggle_complete.dart
import '../repositories/task_repository.dart';
import '../../../../../core/result.dart';

class ToggleTaskComplete {
  final TaskRepository repo;
  ToggleTaskComplete(this.repo);
  Future<Result<void>> call(String taskId) => repo.toggleComplete(taskId);
}