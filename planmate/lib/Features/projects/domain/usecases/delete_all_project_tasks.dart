// delete_all_project_tasks.dart
import '../repositories/task_repository.dart';
import '../../../../../core/result.dart';

class DeleteAllProjectTasks {
  final TaskRepository repo;
  DeleteAllProjectTasks(this.repo);
  Future<Result<void>> call(String projectId) => repo.deleteAllInProject(projectId);
}
