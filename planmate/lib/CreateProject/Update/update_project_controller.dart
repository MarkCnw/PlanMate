import 'package:flutter/material.dart';
import 'package:planmate/Models/project_model.dart';
import 'package:planmate/Services/firebase_project_service.dart';

class UpdateProjectController {
  final ProjectModel project;
  final VoidCallback onStateChanged;
  final VoidCallback? onSuccess; // เพิ่ม callback สำหรับสำเร็จ

  UpdateProjectController({
    required this.project,
    required this.onStateChanged,
    this.onSuccess,
  }) {
    nameController.text = project.title;
    selectedIconKey = project.iconKey;
    selectedIconPath = project.iconPath;
  }

  final FirebaseProjectServices _projectService = FirebaseProjectServices();
  final TextEditingController nameController = TextEditingController();

  // ใช้ข้อมูลจาก ProjectModel แทน hardcode
  Map<String, String> get iconOptionsMap {
    final options = ProjectModel.getIconOptions();
    return options.map((key, value) => MapEntry(key, value.iconPath));
  }

  List<Map<String, String>> get iconOptions {
    final options = ProjectModel.getIconOptions();
    return options.entries.map((entry) => {
      'key': entry.key,
      'path': entry.value.iconPath,
    }).toList();
  }

  String? selectedIconKey;
  String? selectedIconPath;
  bool isLoading = false;
  String? nameError;
  String? iconError;

  void selectIcon(String key, String path) {
    selectedIconKey = key;
    selectedIconPath = path;
    iconError = null;
    onStateChanged();
  }

  void clearNameError() {
    nameError = null;
    onStateChanged();
  }

  void updateProject() async {
    final name = nameController.text.trim();

    // Validation
    if (name.isEmpty) {
      nameError = 'Project name is required';
    } else if (name.length > 50) {
      nameError = 'Project name is too long (max 50 characters)';
    } else {
      nameError = null;
    }

    if (selectedIconPath == null || selectedIconKey == null) {
      iconError = 'Icon selection is required';
    } else {
      iconError = null;
    }

    // ตรวจสอบว่ามีการเปลี่ยนแปลงหรือไม่
    bool hasChanges = name != project.title || selectedIconKey != project.iconKey;
    if (!hasChanges && nameError == null && iconError == null) {
      // ไม่มีการเปลี่ยนแปลง แต่ให้ callback สำเร็จเพื่อปิด modal
      onSuccess?.call();
      return;
    }

    if (nameError != null || iconError != null) {
      onStateChanged();
      return;
    }

    isLoading = true;
    onStateChanged();

    try {
      // ดึงข้อมูลสีที่ตรงกับ iconKey ใหม่
      final iconOptions = ProjectModel.getIconOptions();
      final iconData = iconOptions[selectedIconKey!] ?? iconOptions['rocket']!;

      await _projectService.updateProject(
        projectId: project.id,
        newTitle: name,
        newIconKey: selectedIconKey!,
        newIconPath: iconData.iconPath,
        newColor: iconData.color.value, // ส่งสีไปด้วย
      );

      print('✅ Project updated successfully');
      onSuccess?.call(); // เรียก callback เมื่อสำเร็จ

    } catch (e) {
      print('❌ Failed to update project: $e');
      // แสดง error แต่ไม่ต้องจัดการมากเพราะ UI จะแสดง loading = false
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  void dispose() {
    nameController.dispose();
  }
}