import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planmate/Domain/Activity/activity_log.dart';
import 'package:planmate/Domain/Activity/activity_log_repository.dart';

import 'activity_log_mapper.dart';

class FirestoreActivityLogRepository implements ActivityLogRepository {
  final FirebaseFirestore _db;
  FirestoreActivityLogRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference get _col => _db.collection('activity_logs');

  @override
  Future<void> add(ActivityLog log) => _col.add(ActivityLogMapper.toMap(log));

  @override
  Stream<List<ActivityLog>> watchLatest({int limit = 100}) => _col
      .orderBy('timestamp', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map(ActivityLogMapper.fromDoc).toList());
}
