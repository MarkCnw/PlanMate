import 'package:planmate/Domain/Activity/activity_type.dart';

class ActivityLog {
  final String id;
  final String projectId;
  final String title; // ชื่อ project/task ที่เกี่ยวข้อง
  final ActivityType type;
  final DateTime timestamp;
  
  const ActivityLog({
    required this.id,
    required this.projectId,
    required this.title,
    required this.type,
    required this.timestamp,
  });
}
