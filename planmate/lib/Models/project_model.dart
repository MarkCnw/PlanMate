import 'package:flutter/material.dart';

class ProjectModel {
  final String id;
  final String title;
  final int taskCount;
  final Color color;
  final IconData icon;
  final String? description; // เพิ่ม description (optional)
  final DateTime createdAt; // เพิ่ม createdAt

  ProjectModel({
    required this.id,
    required this.title,
    required this.taskCount,
    required this.color,
    required this.icon,
    this.description,
    required this.createdAt,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      taskCount: map['taskCount'] as int? ?? 0,
      color: Color(map['color'] as int? ?? 0xFF8B5CF6), // default สีม่วง
      icon: IconData(
        map['icon'] as int? ?? Icons.folder.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      description: map['description'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'taskCount': taskCount,
      'color': color.value,
      'icon': icon.codePoint,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Helper method สำหรับสร้าง mock data
  static List<ProjectModel> getMockProjects() {
    return [
      ProjectModel(
        id: '1',
        title: 'Planning Trip',
        taskCount: 12,
        color: const Color(0xFF60A5FA),
        icon: Icons.flight_takeoff,
        description: 'Plan my vacation trip',
        createdAt: DateTime.now(),
      ),
      ProjectModel(
        id: '2',
        title: 'Coding Games',
        taskCount: 12,
        color: const Color(0xFF8B5CF6),
        icon: Icons.code,
        description: 'Learn programming through games',
        createdAt: DateTime.now(),
      ),
      ProjectModel(
        id: '3',
        title: 'Baseketball ',
        taskCount: 12,
        color: const Color.fromARGB(255, 233, 126, 73),
        icon: Icons.sports_basketball,
        description: 'Play basketball with friends',
        createdAt: DateTime.now(),
      ),
    ];
  }

  // Copy with method สำหรับการแก้ไข
  ProjectModel copyWith({
    String? id,
    String? title,
    int? taskCount,
    Color? color,
    IconData? icon,
    String? description,
    DateTime? createdAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      taskCount: taskCount ?? this.taskCount,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
