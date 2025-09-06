// watch_tasks_by_project.dart
import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../../../../core/result.dart';

class WatchTasksByProject {
  final TaskRepository repo;
  WatchTasksByProject(this.repo);
  Stream<Result<List<Task>>> call(String projectId) => repo.watchByProject(projectId);
}