import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProjectIconData {
  final String iconPath;
  final Color color;
  final String name;

  const ProjectIconData({
    required this.iconPath,
    required this.color,
    required this.name,
  });
}

class ProjectModel {
  final String id;
  final String title;
  final int taskCount;
  final Color color;
  final String iconPath;
  final String iconKey; // เพิ่มเพื่อเก็บ key ของไอคอน
  final String userId; // เชื่อมโยงกับ user ที่สร้าง
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt; // เพิ่มเพื่อติดตามการแก้ไข

  ProjectModel({
    required this.id,
    required this.title,
    required this.taskCount,
    required this.color,
    required this.iconPath,
    required this.iconKey,
    required this.userId,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  // Static method สำหรับ Icon Options พร้อมสีที่เฉพาะ
  static Map<String, ProjectIconData> getIconOptions() {
    return {
      'dumbel': const ProjectIconData(
        iconPath: 'assets/newicons/dumbel.png',
        color: Color(0xFFD32F2F), // แดงเข้มพลัง
        name: 'dumbel',
      ),
      'deal': const ProjectIconData(
        iconPath: 'assets/newicons/deal.png',
        color: Color(0xFF00796B), // เขียวเข้มเชื่อมั่น
        name: 'deal',
      ),
      'confetti': const ProjectIconData(
        iconPath: 'assets/newicons/confetti.png',
        color: Color(0xFFF57C00), // ส้มเข้มฉลอง
        name: 'confetti',
      ),
      'music': const ProjectIconData(
        iconPath: 'assets/newicons/music.png',
        color: Color(0xFF303F9F), // น้ำเงินเข้มสดใส
        name: 'music',
      ),
      'clean': const ProjectIconData(
        iconPath: 'assets/newicons/clean.png',
        color: Color(0xFFFBC02D), // เหลืองทองสด
        name: 'clean',
      ),
      'medical': const ProjectIconData(
        iconPath: 'assets/newicons/medical.png',
        color: Color(0xFF7B1FA2), // ม่วงเข้ม
        name: 'medical',
      ),
      'struggle': const ProjectIconData(
        iconPath: 'assets/newicons/struggle.png',
        color: Color(0xFFC2185B), // ชมพูแดงแรง
        name: 'struggle',
      ),
      'camping': const ProjectIconData(
        iconPath: 'assets/newicons/camping.png',
        color: Color(0xFF2E7D32), // เขียวป่าเข้ม
        name: 'camping',
      ),
      'creativity': const ProjectIconData(
        iconPath: 'assets/newicons/creativity.png',
        color: Color(0xFF512DA8), // ม่วงเข้มสร้างสรรค์
        name: 'creativity',
      ),
      'family': const ProjectIconData(
        iconPath: 'assets/newicons/family.png',
        color: Color(0xFF0288D1), // ฟ้าเด่นสด
        name: 'family',
      ),
      'books': const ProjectIconData(
        iconPath: 'assets/newicons/books.png',
        color: Color(0xFF6D4C41), // น้ำตาลเข้มคลาสสิค
        name: 'books',
      ),
      'star': const ProjectIconData(
        iconPath: 'assets/newicons/star.png',
        color: Color(0xFFFBC02D), // เหลืองทองเด่น
        name: 'star',
      ),
      'stalking': const ProjectIconData(
        iconPath: 'assets/newicons/stalking.png',
        color: Color(0xFFE0F7FA), // ฟ้าอมเขียวอ่อน (Mint Blue)
        name: 'stalking',
      ),

      'project': const ProjectIconData(
        iconPath: 'assets/newicons/project.png',
        color: Color(0xFF424242), // เทาเข้ม
        name: 'project',
      ),
      'fast': const ProjectIconData(
        iconPath: 'assets/newicons/fast.png',
        color: Color(0xFF00796B), // เขียวมิ้นต์เข้ม
        name: 'fast',
      ),
      'planets': const ProjectIconData(
        iconPath: 'assets/newicons/planets.png',
        color: Color(0xFF6A1B9A), // ม่วงอวกาศ
        name: 'planets',
      ),
      'idea': const ProjectIconData(
        iconPath: 'assets/newicons/idea.png',
        color: Color(0xFFF57F17), // เหลืองส้มสด
        name: 'idea',
      ),
      'guitar': const ProjectIconData(
        iconPath: 'assets/newicons/guitar.png',
        color: Color(0xFFE65100), // ส้มเข้ม
        name: 'guitar',
      ),
      'dyslexia': const ProjectIconData(
        iconPath: 'assets/newicons/dyslexia.png',
        color: Color(0xFF455A64), // เทาน้ำเงินเข้ม
        name: 'dyslexia',
      ),
      'icecream': const ProjectIconData(
        iconPath: 'assets/newicons/icecream.png',
        color: Color(0xFFD81B60), // ชมพูเข้มหวาน
        name: 'icecream',
      ),
    };
  }

  // Factory method สำหรับสร้างโปรเจคใหม่
  factory ProjectModel.create({
    required String title,
    required String iconKey,
    required String userId,
    String? description,
  }) {
    final iconOptions = getIconOptions();
    final iconData =
        iconOptions[iconKey] ??
        iconOptions['rocket']!; // default เป็น rocket

    return ProjectModel(
      id: '', // Firestore จะ generate ให้
      title: title.trim(),
      taskCount: 0,
      color: iconData.color,
      iconPath: iconData.iconPath,
      iconKey: iconKey,
      userId: userId,
      description: description?.trim(),
      createdAt: DateTime.now(),
    );
  }

  // Factory method จาก Firestore data
  factory ProjectModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return ProjectModel(
      id: docId ?? map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      taskCount: map['taskCount'] as int? ?? 0,
      color: Color(map['color'] as int? ?? 0xFF8B5CF6),
      iconPath: map['iconPath'] as String? ?? 'assets/icons/rocket.png',
      iconKey: map['iconKey'] as String? ?? 'rocket',
      userId: map['userId'] as String? ?? '',
      description: map['description'] as String?,

      // 🔥 แก้ไขการจัดการ DateTime จาก Firestore
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is DateTime) {
      return value;
    }

    return null;
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'taskCount': taskCount,
      'color': color.value,
      'iconPath': iconPath,
      'iconKey': iconKey,
      'userId': userId,
      'description': description,

      // 🔥 ใช้ Timestamp สำหรับ Firestore
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Validation methods
  bool get isValid => title.trim().isNotEmpty && userId.isNotEmpty;

  String? validateTitle() {
    if (title.trim().isEmpty) return 'Project name is required';
    if (title.length > 50)
      return 'Project name is too long (max 50 characters)';
    return null;
  }

  String? validateDescription() {
    if (description != null && description!.length > 200) {
      return 'Description is too long (max 200 characters)';
    }
    return null;
  }

  // Helper methods
  bool get hasDescription =>
      description != null && description!.trim().isNotEmpty;

  bool get hasTasks => taskCount > 0;

  String get taskCountText =>
      taskCount == 1 ? '1 task' : '$taskCount tasks';

  // ตรวจสอบว่าเป็นของ user นี้หรือไม่
  bool belongsToUser(String uid) => userId == uid;

  // Static method สำหรับ Mock data (สำหรับ development)
  static List<ProjectModel> getMockProjects() {
    return [
      ProjectModel(
        id: '1',
        title: 'Planning Trip',
        taskCount: 12,
        color: const Color(0xFF60A5FA),
        iconPath: 'assets/icons/book.png',
        iconKey: 'travel',
        userId: 'mock_user_1',
        description: 'Plan my vacation trip to Japan',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ProjectModel(
        id: '2',
        title: 'Play Sport',
        taskCount: 8,
        color: const Color(0xFF8B5CF6),
        iconPath: 'assets/icons/Football.png',
        iconKey: 'coding',
        userId: 'mock_user_1',
        description: 'Learn programming through interactive games',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ProjectModel(
        id: '3',
        title: 'Chess Training',
        taskCount: 15,
        color: const Color(0xFFFF6B35),
        iconPath: 'assets/icons/Chess.png',
        iconKey: 'basketball',
        userId: 'mock_user_1',
        description: 'Improve basketball skills and fitness',
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
    String? iconPath,
    String? iconKey,
    String? userId,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      taskCount: taskCount ?? this.taskCount,
      color: color ?? this.color,
      iconPath: iconPath ?? this.iconPath,
      iconKey: iconKey ?? this.iconKey,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Update task count
  ProjectModel updateTaskCount(int newCount) {
    return copyWith(taskCount: newCount, updatedAt: DateTime.now());
  }

  // Update project info
  ProjectModel updateInfo({
    String? title,
    String? description,
    String? iconKey,
  }) {
    final iconOptions = getIconOptions();
    final newIconKey = iconKey ?? this.iconKey;
    final iconData = iconOptions[newIconKey] ?? iconOptions[this.iconKey]!;

    return copyWith(
      title: title,
      description: description,
      iconKey: newIconKey,
      iconPath: iconData.iconPath,
      color: iconData.color,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ProjectModel(id: $id, title: $title, taskCount: $taskCount, iconKey: $iconKey, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
