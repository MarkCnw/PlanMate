import 'package:planmate/Domain/Activity/activity_log.dart';
import 'package:planmate/Domain/Activity/activity_log_repository.dart';

class WatchActivityLogs {
  final ActivityLogRepository repo;
  WatchActivityLogs(this.repo);
  Stream<List<ActivityLog>> call({int limit = 100}) => repo.watchLatest(limit: limit);
}
