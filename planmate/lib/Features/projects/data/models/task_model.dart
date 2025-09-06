// =====================================================
// features/projects/data/models/task_model.dart
// =====================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task.dart' as domain;

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final bool isDone;
  final String projectId;
  final String userId;
  final DateTime? createdAt; // may be null right after creation (server timestamp)
  final DateTime? updatedAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final domain.TaskPriority priority;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.isDone,
    required this.projectId,
    required this.userId,
    this.createdAt,
    this.updatedAt,
    this.dueDate,
    this.completedAt,
    this.priority = domain.TaskPriority.medium,
  });

  factory TaskModel.fromEntity(domain.Task e) => TaskModel(
        id: e.id,
        title: e.title,
        description: e.description,
        isDone: e.isDone,
        projectId: e.projectId,
        userId: e.userId,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
        dueDate: e.dueDate,
        completedAt: e.completedAt,
        priority: e.priority,
      );

  domain.Task toEntity() => domain.Task(
        id: id,
        title: title,
        description: description,
        isDone: isDone,
        projectId: projectId,
        userId: userId,
        createdAt: createdAt ?? DateTime.now(),
        updatedAt: updatedAt,
        dueDate: dueDate,
        completedAt: completedAt,
        priority: priority,
      );

  factory TaskModel.fromMap(Map<String, dynamic> map, {String? docId}) => TaskModel(
        id: docId ?? (map['id'] as String? ?? ''),
        title: (map['title'] as String? ?? '').trim(),
        description: (map['description'] as String?)?.trim(),
        isDone: map['isDone'] as bool? ?? false,
        projectId: map['projectId'] as String? ?? '',
        userId: map['userId'] as String? ?? '',
        createdAt: _dt(map['createdAt']),
        updatedAt: _dt(map['updatedAt']),
        dueDate: _dt(map['dueDate']),
        completedAt: _dt(map['completedAt']),
        priority: _priorityFrom(map['priority']),
      );

  static TaskModel fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return TaskModel.fromMap(data, docId: doc.id);
  }

  Map<String, dynamic> toMapForCreate() => {
        'title': title,
        'description': description,
        'isDone': isDone,
        'projectId': projectId,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(), // server time ✅
        if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate!),
        'priority': _priorityToInt(priority),
      };

  Map<String, dynamic> toMapForUpdate() => {
        if (title.isNotEmpty) 'title': title,
        'description': description, // allow null to clear
        'isDone': isDone,
        'projectId': projectId,
        'userId': userId,
        'updatedAt': FieldValue.serverTimestamp(),
        if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate!) else 'dueDate': null,
        if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!) else 'completedAt': null,
        'priority': _priorityToInt(priority),
      };

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isDone,
    String? projectId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    DateTime? completedAt,
    domain.TaskPriority? priority,
  }) => TaskModel(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        isDone: isDone ?? this.isDone,
        projectId: projectId ?? this.projectId,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        dueDate: dueDate ?? this.dueDate,
        completedAt: completedAt ?? this.completedAt,
        priority: priority ?? this.priority,
      );

  static DateTime? _dt(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is DateTime) return v;
    return null;
  }

  static domain.TaskPriority _priorityFrom(dynamic v) {
    if (v is int) {
      return switch (v) { 1 => domain.TaskPriority.high, 3 => domain.TaskPriority.low, _ => domain.TaskPriority.medium };
    }
    if (v is String) {
      final s = v.toLowerCase();
      if (s == 'high') return domain.TaskPriority.high;
      if (s == 'low') return domain.TaskPriority.low;
      return domain.TaskPriority.medium;
    }
    return domain.TaskPriority.medium;
  }

  static int _priorityToInt(domain.TaskPriority p) => switch (p) {
        domain.TaskPriority.high => 1,
        domain.TaskPriority.medium => 2,
        domain.TaskPriority.low => 3,
      };
}

