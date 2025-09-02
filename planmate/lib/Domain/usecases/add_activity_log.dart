import 'package:planmate/Domain/Activity/activity_log.dart';
import 'package:planmate/Domain/Activity/activity_log_repository.dart';

class AddActivityLog {
  final ActivityLogRepository repo;
  AddActivityLog(this.repo);
  Future<void> call(ActivityLog log) => repo.add(log);
}
