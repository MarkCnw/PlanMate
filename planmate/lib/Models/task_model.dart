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
  
  // ✅ Features ที่เหลือ (ลบ time tracking)
  final DateTime? startedAt; // เวลาที่เริ่มทำ
  final double progress; // ความคืบหน้า 0.0-1.0
  final TaskStatus status; // สถานะของ task

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
    this.priority = 2,
    this.startedAt,
    this.progress = 0.0,
    this.status = TaskStatus.pending,
  });

  // Factory method สำหรับสร้าง task ใหม่
  factory TaskModel.create({
    required String title,
    required String projectId,
    required String userId,
    String? description,
    DateTime? dueDate,
    int priority = 2,
    Duration? estimatedDuration, // เก็บไว้เพื่อ compatibility แต่จะไม่ใช้
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
      progress: 0.0,
      status: TaskStatus.pending,
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
      startedAt: _parseDateTime(map['startedAt']),
      priority: map['priority'] as int? ?? 2,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      status: TaskStatus.fromString(map['status'] as String? ?? 'pending'),
    );
  }

  // Helper methods for parsing
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
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'priority': priority,
      'progress': progress,
      'status': status.value,
    };
  }

  // Helper getters
  bool get hasDescription => description != null && description!.trim().isNotEmpty;
  bool get hasDueDate => dueDate != null;
  bool get isStarted => startedAt != null;
  bool get isInProgress => status == TaskStatus.inProgress;
  bool get isCompleted => isDone;
  
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

  String get statusText {
    switch (status) {
      case TaskStatus.pending: return 'Pending';
      case TaskStatus.inProgress: return 'In Progress';
      case TaskStatus.completed: return 'Completed';
      default: return 'Pending';
    }
  }

  // ✅ Progress helpers
  String get progressText => '${(progress * 100).toInt()}%';
  
  bool get hasProgress => progress > 0.0;

  // Copy with method (simplified)
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
    DateTime? startedAt,
    int? priority,
    double? progress,
    TaskStatus? status,
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
      startedAt: startedAt ?? this.startedAt,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      status: status ?? this.status,
    );
  }

  // ✅ Simplified actions (ไม่มี pause/start)
  TaskModel completeTask() {
    return copyWith(
      isDone: true,
      status: TaskStatus.completed,
      completedAt: DateTime.now(),
      progress: 1.0,
      updatedAt: DateTime.now(),
    );
  }

  TaskModel updateProgress(double newProgress) {
    final clampedProgress = newProgress.clamp(0.0, 1.0);
    TaskStatus newStatus = status;
    
    if (clampedProgress >= 1.0 && !isDone) {
      newStatus = TaskStatus.completed;
    } else if (clampedProgress > 0.0 && status == TaskStatus.pending) {
      newStatus = TaskStatus.inProgress;
    }

    return copyWith(
      progress: clampedProgress,
      status: newStatus,
      isDone: clampedProgress >= 1.0,
      completedAt: clampedProgress >= 1.0 ? DateTime.now() : null,
      startedAt: startedAt ?? (clampedProgress > 0.0 ? DateTime.now() : null),
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, progress: $progressText, status: ${status.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ✅ Task Status Enum (ลบ paused)
enum TaskStatus {
  pending('pending'),
  inProgress('in_progress'),
  completed('completed');

  const TaskStatus(this.value);
  final String value;

  static TaskStatus fromString(String value) {
    switch (value) {
      case 'in_progress': return TaskStatus.inProgress;
      case 'completed': return TaskStatus.completed;
      default: return TaskStatus.pending;
    }
  }
}