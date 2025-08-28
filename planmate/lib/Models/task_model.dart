import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final bool isDone;
  final String projectId;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final int priority; // 1-3 (1=high, 2=medium, 3=low)

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.isDone,
    required this.projectId,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
    this.dueDate,
    this.completedAt,
    this.priority = 2, // default medium
  });

  // Factory method สำหรับสร้าง task ใหม่
  factory TaskModel.create({
    required String title,
    required String projectId,
    required String userId,
    String? description,
    DateTime? dueDate,
    int priority = 2,
  }) {
    return TaskModel(
      id: '', // Firestore จะ generate ให้
      title: title.trim(),
      description: description?.trim(),
      isDone: false,
      projectId: projectId,
      userId: userId,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      priority: priority,
    );
  }

  // Factory method จาก Firestore
  factory TaskModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return TaskModel(
      id: docId ?? map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      isDone: map['isDone'] as bool? ?? false,
      projectId: map['projectId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(map['updatedAt']),
      dueDate: _parseDateTime(map['dueDate']),
      completedAt: _parseDateTime(map['completedAt']),
      priority: map['priority'] as int? ?? 2,
    );
  }

  // Helper method สำหรับ parse DateTime
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is DateTime) return value;
    return null;
  }

  // Convert to Map สำหรับ Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
      'projectId': projectId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'priority': priority,
    };
  }

  // Validation methods
  bool get isValid => title.trim().isNotEmpty && projectId.isNotEmpty && userId.isNotEmpty;

  String? validateTitle() {
    if (title.trim().isEmpty) return 'Task title is required';
    if (title.length > 100) return 'Task title is too long (max 100 characters)';
    return null;
  }

  String? validateDescription() {
    if (description != null && description!.length > 500) {
      return 'Description is too long (max 500 characters)';
    }
    return null;
  }

  // Helper getters
  bool get hasDescription => description != null && description!.trim().isNotEmpty;
  bool get hasDueDate => dueDate != null;
  bool get isOverdue {
    if (dueDate == null || isDone) return false;
    return DateTime.now().isAfter(dueDate!);
  }
  
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return now.year == dueDate!.year &&
           now.month == dueDate!.month &&
           now.day == dueDate!.day;
  }

  String get priorityText {
    switch (priority) {
      case 1: return 'High';
      case 2: return 'Medium';
      case 3: return 'Low';
      default: return 'Medium';
    }
  }

  String get statusText => isDone ? 'Completed' : 'Pending';

  // Copy with method
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
    int? priority,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
    );
  }

  // Toggle completion status
  TaskModel toggleComplete() {
    return copyWith(
      isDone: !isDone,
      completedAt: !isDone ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );
  }

  // Update task info
  TaskModel updateInfo({
    String? title,
    String? description,
    DateTime? dueDate,
    int? priority,
  }) {
    return copyWith(
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, isDone: $isDone, projectId: $projectId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}