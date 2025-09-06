// create_task.dart
import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../../../../core/result.dart';

class CreateTask {
  final TaskRepository repo;
  CreateTask(this.repo);
  Future<Result<String>> call(Task task) => repo.create(task);
}