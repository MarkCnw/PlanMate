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
  
  // ✅ เพิ่มฟีเจอร์ใหม่
  final Duration? estimatedDuration; // เวลาที่ประมาณการ
  final Duration? actualDuration; // เวลาที่ใช้จริง
  final DateTime? startedAt; // เวลาที่เริ่มทำ
  final double progress; // ความคืบหน้า 0.0-1.0
  final List<TimeEntry> timeEntries; // รายการบันทึกเวลา
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
    this.estimatedDuration,
    this.actualDuration,
    this.startedAt,
    this.progress = 0.0,
    this.timeEntries = const [],
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
    Duration? estimatedDuration,
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
      estimatedDuration: estimatedDuration,
      progress: 0.0,
      status: TaskStatus.pending,
      timeEntries: [],
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
      estimatedDuration: _parseDuration(map['estimatedDuration']),
      actualDuration: _parseDuration(map['actualDuration']),
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      status: TaskStatus.fromString(map['status'] as String? ?? 'pending'),
      timeEntries: _parseTimeEntries(map['timeEntries'] as List?),
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

  static Duration? _parseDuration(dynamic value) {
    if (value == null) return null;
    if (value is int) return Duration(minutes: value);
    if (value is Map) {
      final minutes = value['minutes'] as int?;
      final hours = value['hours'] as int?;
      return Duration(
        hours: hours ?? 0,
        minutes: minutes ?? 0,
      );
    }
    return null;
  }

  static List<TimeEntry> _parseTimeEntries(List? entries) {
    if (entries == null) return [];
    return entries
        .map((e) => TimeEntry.fromMap(e as Map<String, dynamic>))
        .toList();
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
      'estimatedDuration': estimatedDuration?.inMinutes,
      'actualDuration': actualDuration?.inMinutes,
      'progress': progress,
      'status': status.value,
      'timeEntries': timeEntries.map((e) => e.toMap()).toList(),
    };
  }

  // Helper getters
  bool get hasDescription => description != null && description!.trim().isNotEmpty;
  bool get hasDueDate => dueDate != null;
  bool get hasEstimatedTime => estimatedDuration != null;
  bool get isStarted => startedAt != null;
  bool get isInProgress => status == TaskStatus.inProgress;
  bool get isCompleted => isDone;
  bool get isPaused => status == TaskStatus.paused;
  
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
      case TaskStatus.paused: return 'Paused';
      case TaskStatus.completed: return 'Completed';
      default: return 'Pending';
    }
  }

  // ✅ Progress helpers
  String get progressText => '${(progress * 100).toInt()}%';
  
  bool get hasProgress => progress > 0.0;
  
  // ✅ Time tracking helpers
  Duration get totalTimeSpent {
    return timeEntries.fold(Duration.zero, (total, entry) => total + entry.duration);
  }

  String get estimatedTimeText {
    if (estimatedDuration == null) return 'No estimate';
    final hours = estimatedDuration!.inHours;
    final minutes = estimatedDuration!.inMinutes % 60;
    
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  String get actualTimeText {
    final spent = totalTimeSpent;
    final hours = spent.inHours;
    final minutes = spent.inMinutes % 60;
    
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  // Time efficiency
  double? get timeEfficiency {
    if (estimatedDuration == null) return null;
    final spent = totalTimeSpent;
    if (spent.inMinutes == 0) return null;
    
    return estimatedDuration!.inMinutes / spent.inMinutes;
  }

  // Copy with method (enhanced)
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
    Duration? estimatedDuration,
    Duration? actualDuration,
    double? progress,
    TaskStatus? status,
    List<TimeEntry>? timeEntries,
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
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      timeEntries: timeEntries ?? this.timeEntries,
    );
  }

  // ✅ Enhanced actions
  TaskModel startTask() {
    return copyWith(
      status: TaskStatus.inProgress,
      startedAt: startedAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  TaskModel pauseTask() {
    return copyWith(
      status: TaskStatus.paused,
      updatedAt: DateTime.now(),
    );
  }

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

  TaskModel addTimeEntry(TimeEntry entry) {
    final updatedEntries = List<TimeEntry>.from(timeEntries)..add(entry);
    return copyWith(
      timeEntries: updatedEntries,
      actualDuration: totalTimeSpent + entry.duration,
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

// ✅ Task Status Enum
enum TaskStatus {
  pending('pending'),
  inProgress('in_progress'),
  paused('paused'),
  completed('completed');

  const TaskStatus(this.value);
  final String value;

  static TaskStatus fromString(String value) {
    switch (value) {
      case 'in_progress': return TaskStatus.inProgress;
      case 'paused': return TaskStatus.paused;
      case 'completed': return TaskStatus.completed;
      default: return TaskStatus.pending;
    }
  }
}

// ✅ Time Entry Model
class TimeEntry {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String? description;

  TimeEntry({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.description,
  });

  Duration get duration => endTime.difference(startTime);

  factory TimeEntry.fromMap(Map<String, dynamic> map) {
    return TimeEntry(
      id: map['id'] as String? ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'description': description,
    };
  }

  static TimeEntry create({
    required DateTime startTime,
    required DateTime endTime,
    String? description,
  }) {
    return TimeEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: startTime,
      endTime: endTime,
      description: description,
    );
  }
}