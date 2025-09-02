import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planmate/Domain/Activity/activity_log.dart';
import 'package:planmate/Domain/Activity/activity_type.dart';


class ActivityLogMapper {
  static Map<String, dynamic> toMap(ActivityLog x) => {
    'projectId': x.projectId,
    'title': x.title,
    'type': x.type.name,
    'timestamp': Timestamp.fromDate(x.timestamp),
  };

  static ActivityLog fromDoc(DocumentSnapshot d) {
    final j = d.data() as Map<String, dynamic>;
    return ActivityLog(
      id: d.id,
      projectId: j['projectId'] as String,
      title: (j['title'] ?? '') as String,
      type: ActivityType.values.firstWhere((e)=> e.name == j['type']),
      timestamp: (j['timestamp'] as Timestamp).toDate(),
    );
  }
}
