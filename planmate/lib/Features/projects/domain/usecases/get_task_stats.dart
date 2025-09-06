

// get_task_stats.dart
import '../repositories/task_repository.dart';
import '../../../../../core/result.dart';

class GetTaskStats {
  final TaskRepository repo;
  GetTaskStats(this.repo);
  Future<Result<Map<String, int>>> call(String projectId) => repo.stats(projectId);
}