import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final bool done;
  final DateTime? dueDate;
  final DateTime createdAt;
  final String userId;

  TaskModel({
    required this.id,
    required this.title,
    this.done = false,
    this.dueDate,
    required this.createdAt,
    required this.userId,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String docId) {
    return TaskModel(
      id: docId,
      title: map['title'] ?? '',
      done: map['done'] ?? false,
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] as Timestamp).toDate()
          : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'done': done,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    bool? done,
    DateTime? dueDate,
    DateTime? createdAt,
    String? userId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}
