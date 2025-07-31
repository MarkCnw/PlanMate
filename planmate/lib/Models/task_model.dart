import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String? description; 
  final bool done;
  
  final DateTime? dueDate;
  final DateTime createdAt;
  final String userId;
  final DateTime? completedAt; 
  final String? projectId; // เพิ่ม Project ID

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.done = false,
    this.dueDate,
    required this.createdAt,
    required this.userId,
    this.completedAt,
    this.projectId, // เพิ่มใน constructor
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
      description: map['description'],
      done: map['done'] ?? false,
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] as Timestamp).toDate()
          : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      projectId: map['projectId'], // Handle projectId
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'done': done,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'projectId': projectId, // Add projectId to map
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? done,
    DateTime? dueDate,
    DateTime? createdAt,
    String? userId,
    DateTime? completedAt,
    String? projectId, // Add projectId to copyWith
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      done: done ?? this.done,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      completedAt: completedAt ?? this.completedAt,
      projectId: projectId ?? this.projectId, // Handle projectId
    );
  }
}