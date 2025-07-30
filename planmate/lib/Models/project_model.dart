import 'package:flutter/material.dart';

class ProjectModel {
  final String id;
  final String title;
  final int taskCount;
  final Color color;
  final String iconPath; // ✅ ใช้ path แทน IconData
  final String? description;
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.title,
    required this.taskCount,
    required this.color,
    required this.iconPath,
    this.description,
    required this.createdAt,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      taskCount: map['taskCount'] as int? ?? 0,
      color: Color(map['color'] as int? ?? 0xFF8B5CF6),
      iconPath: map['iconPath'] as String? ?? 'assets/icons/default.png',
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
      'iconPath': iconPath, // ✅ บันทึก path แทน codePoint
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  static List<ProjectModel> getMockProjects() {
    return [
      ProjectModel(
        id: '1',
        title: 'Planning Trip',
        taskCount: 12,
        color: const Color(0xFF60A5FA),
        iconPath: 'assets/icons/Pizza.png',
        description: 'Plan my vacation trip',
        createdAt: DateTime.now(),
      ),
      ProjectModel(
        id: '2',
        title: 'Coding Games',
        taskCount: 12,
        color: const Color(0xFF8B5CF6),
        iconPath: 'assets/icons/rocket.png',
        description: 'Learn programming through games',
        createdAt: DateTime.now(),
      ),
      ProjectModel(
        id: '3',
        title: 'Basketball',
        taskCount: 12,
        color: const Color.fromARGB(255, 233, 126, 73),
        iconPath: 'assets/icons/check&cal.png',
        description: 'Play basketball with friends',
        createdAt: DateTime.now(),
      ),
    ];
  }

  ProjectModel copyWith({
    String? id,
    String? title,
    int? taskCount,
    Color? color,
    String? iconPath,
    String? description,
    DateTime? createdAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      taskCount: taskCount ?? this.taskCount,
      color: color ?? this.color,
      iconPath: iconPath ?? this.iconPath,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
