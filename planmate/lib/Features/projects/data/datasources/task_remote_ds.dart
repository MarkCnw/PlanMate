// =====================================================
// features/projects/data/datasources/task_remote_ds.dart
// =====================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_model.dart';

class TaskRemoteDataSource {
  final FirebaseFirestore _fs;
  final FirebaseAuth _auth;
  TaskRemoteDataSource(this._fs, this._auth);

  CollectionReference<Map<String, dynamic>> get tasks => _fs.collection('tasks');
  CollectionReference<Map<String, dynamic>> get projects => _fs.collection('projects');
  String? get uid => _auth.currentUser?.uid;

  Future<String> create(TaskModel m) async {
    if (uid == null) throw 'auth';
    await _verifyOwnership(m.projectId);

    final batch = _fs.batch();
    final ref = tasks.doc();

    // ensure userId set from auth
    final data = m.copyWith(userId: uid!).toMapForCreate();

    batch.set(ref, data);
    batch.update(projects.doc(m.projectId), {
      'taskCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    return ref.id;
  }

  Stream<List<TaskModel>> watchByProject(String projectId) {
    if (uid == null) return const Stream.empty();
    return tasks
        .where('projectId', isEqualTo: projectId)
        .where('userId', isEqualTo: uid)
        // .orderBy('createdAt') // ✅ เปิดใช้ได้ถ้าทุก doc มี field นี้ครบ
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(TaskModel.fromDoc).toList();
      list.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aTime.compareTo(bTime);
      });
      return list;
    });
  }

  Future<void> toggleComplete(String taskId) async {
    if (uid == null) throw 'auth';
    final doc = await tasks.doc(taskId).get();
    if (!doc.exists) throw 'not_found';
    final data = doc.data()!;
    if (data['userId'] != uid) throw 'forbidden';

    final curr = (data['isDone'] as bool?) ?? false;
    await tasks.doc(taskId).update({
      'isDone': !curr,
      'completedAt': !curr ? FieldValue.serverTimestamp() : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> update({
    required String taskId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? priority,
  }) async {
    if (uid == null) throw 'auth';

    final doc = await tasks.doc(taskId).get();
    if (!doc.exists) throw 'not_found';
    final data = doc.data()!;
    if (data['userId'] != uid) throw 'forbidden';

    final update = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (title != null) {
      final t = title.trim();
      if (t.isEmpty) throw 'title_required';
      if (t.length > 100) throw 'title_too_long';
      update['title'] = t;
    }

    if (description != null) {
      final d = description.trim();
      if (d.isNotEmpty && d.length > 500) throw 'desc_too_long';
      update['description'] = d.isEmpty ? null : d;
    }

    if (dueDate != null) {
      update['dueDate'] = Timestamp.fromDate(dueDate);
    }

    if (priority != null) {
      if (priority < 1 || priority > 3) throw 'priority_range';
      update['priority'] = priority;
    }

    await tasks.doc(taskId).update(update);
  }

  Future<void> delete(String taskId) async {
    if (uid == null) throw 'auth';
    final doc = await tasks.doc(taskId).get();
    if (!doc.exists) throw 'not_found';
    final data = doc.data()!;
    if (data['userId'] != uid) throw 'forbidden';

    final projectId = data['projectId'] as String;

    final batch = _fs.batch();
    batch.delete(tasks.doc(taskId));
    batch.update(projects.doc(projectId), {
      'taskCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> deleteAllInProject(String projectId) async {
    if (uid == null) throw 'auth';
    await _verifyOwnership(projectId);

    final q = await tasks
        .where('projectId', isEqualTo: projectId)
        .where('userId', isEqualTo: uid)
        .get();

    if (q.docs.isEmpty) return;

    final batch = _fs.batch();
    for (final d in q.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }

  Future<Map<String, int>> stats(String projectId) async {
    if (uid == null) throw 'auth';
    final q = await tasks
        .where('projectId', isEqualTo: projectId)
        .where('userId', isEqualTo: uid)
        .get();

    int total = 0, completed = 0, pending = 0, overdue = 0;
    for (final d in q.docs) {
      total += 1;
      final data = d.data();
      final done = data['isDone'] as bool? ?? false;
      if (done) {
        completed += 1;
      } else {
        pending += 1;
        final ts = data['dueDate'];
        DateTime? due;
        if (ts is Timestamp) due = ts.toDate();
        if (due != null && DateTime.now().isAfter(due)) overdue += 1;
      }
    }
    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'overdue': overdue,
    };
  }

  Future<void> _verifyOwnership(String projectId) async {
    final d = await projects.doc(projectId).get();
    if (!d.exists) throw 'project_not_found';
    if ((d.data()?['userId']) != uid) throw 'forbidden';
  }
}

