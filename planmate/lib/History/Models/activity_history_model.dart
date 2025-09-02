import 'dart:convert';

enum ActivityType {
  create,
  update,
  complete,
  delete;

  String get displayName {
    switch (this) {
      case ActivityType.create:
        return 'สร้าง';
      case ActivityType.update:
        return 'แก้ไข';
      case ActivityType.complete:
        return 'เสร็จ';
      case ActivityType.delete:
        return 'ลบ';
    }
  }

  String get value => name;

  static ActivityType fromString(String value) {
    return ActivityType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => ActivityType.create,
    );
  }
}

class ActivityHistoryModel {
  final String id;
  final ActivityType type;
  final String projectId;
  final String? taskId;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ActivityHistoryModel({
    required this.id,
    required this.type,
    required this.projectId,
    this.taskId,
    required this.description,
    required this.timestamp,
    this.metadata,
  });

  ActivityHistoryModel copyWith({
    String? id,
    ActivityType? type,
    String? projectId,
    String? taskId,
    String? description,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return ActivityHistoryModel(
      id: id ?? this.id,
      type: type ?? this.type,
      projectId: projectId ?? this.projectId,
      taskId: taskId ?? this.taskId,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'type': type.value,
      'projectId': projectId,
      'taskId': taskId,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ActivityHistoryModel.fromMap(Map<String, dynamic> map) {
    return ActivityHistoryModel(
      id: map['id'] as String,
      type: ActivityType.fromString(map['type'] as String),
      projectId: map['projectId'] as String,
      taskId: map['taskId'] != null ? map['taskId'] as String : null,
      description: map['description'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      metadata:
          map['metadata'] != null
              ? Map<String, dynamic>.from(
                map['metadata'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ActivityHistoryModel.fromJson(String source) =>
      ActivityHistoryModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() {
    return 'ActivityHistoryModel(id: $id, type: $type, projectId: $projectId, taskId: $taskId, description: $description, timestamp: $timestamp, metadata: $metadata)';
  }

  @override
  bool operator ==(covariant ActivityHistoryModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.type == type &&
        other.projectId == projectId &&
        other.taskId == taskId &&
        other.description == description &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        projectId.hashCode ^
        taskId.hashCode ^
        description.hashCode ^
        timestamp.hashCode;
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'เมื่อสักครู่';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} วันที่แล้ว';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  static ActivityHistoryModel create({
    required ActivityType type,
    required String projectId,
    String? taskId,
    required String description,
    Map<String, dynamic>? metadata,
  }) {
    return ActivityHistoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      projectId: projectId,
      taskId: taskId,
      description: description,
      timestamp: DateTime.now(),
      metadata: metadata,
    );
  }
}
