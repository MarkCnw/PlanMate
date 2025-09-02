import 'package:planmate/Domain/Activity/activity_log.dart';

abstract class ActivityLogRepository {
  Future<void> add(ActivityLog log);
  Stream<List<ActivityLog>> watchLatest({int limit});
}
