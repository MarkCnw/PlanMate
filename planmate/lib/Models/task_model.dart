// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final bool done;
  final DateTime? dueDate;
  final DateTime createdAt;
  final String userId;
  final DateTime? completedAt; // เวลาที่ทำเสร็จ

  TaskModel({
    required this.id,
    required this.title,
    this.done = false,
    this.dueDate,
    required this.createdAt,
    required this.userId,
    this.completedAt,
  });

  // Getter methods
  bool get isOverdue {
    if (dueDate == null || done) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isToday {
    final now = DateTime.now();
    final taskDate = createdAt;
    return now.year == taskDate.year &&
           now.month == taskDate.month &&
           now.day == taskDate.day;
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return now.year == dueDate!.year &&
           now.month == dueDate!.month &&
           now.day == dueDate!.day;
  }

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
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'done': done,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    bool? done,
    DateTime? dueDate,
    DateTime? createdAt,
    String? userId,
    DateTime? completedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}