// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:planmate/Auth/services/google_service.dart';
import 'package:planmate/Models/project_model.dart';
import 'package:planmate/Services/firebase_project_service.dart';

class CreateProjectController {
  final VoidCallback onStateChanged;
  final void Function(ProjectModel project)? onSuccess; // ✅ เพิ่มนี้
  final VoidCallback? onError; // ✅ เพิ่มนี้

  CreateProjectController({
    required this.onStateChanged,
    this.onSuccess,
    this.onError,
  });

  final FirebaseProjectServices _projectService =
      FirebaseProjectServices();
  final FirebaseServices _firebaseServices = FirebaseServices();
  final TextEditingController nameController = TextEditingController();

  Map<String, ProjectIconData> get iconOptionsMap {
    return ProjectModel.getIconOptions();
  }

  List<Map<String, String>> get iconOptions {
    return iconOptionsMap.entries
        .map((entry) => {'key': entry.key, 'path': entry.value.iconPath})
        .toList();
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

  bool validateForm() {
    nameError = null;
    iconError = null;

    bool isValid = true;

    final name = nameController.text.trim();

    if (name.isEmpty) {
      nameError = 'Project name is required';
      isValid = false;
    } else if (name.length > 50) {
      nameError = 'Project name is too long (max 50 characters)';
      isValid = false;
    }

    if (selectedIconPath == null || selectedIconKey == null) {
      iconError = 'Icon selection is required';
      isValid = false;
    }

    onStateChanged();
    return isValid;
  }

  Future<void> createProject() async { // ✅ เปลี่ยนเป็น void
    final uid = _firebaseServices.getCurrentUser()?.uid;
    if (uid == null) {
      onError?.call(); // ✅ เรียก callback แทน return
      return;
    }
    
    if (!validateForm()) return; // ✅ เอา return null ออก

    isLoading = true;
    onStateChanged();
    
    try {
      final id = await _projectService.createProject(
        title: nameController.text.trim(),
        iconKey: selectedIconKey!,
        description: null,
      );
      
      if (id.isEmpty) {
        onError?.call(); // ✅ เรียก callback แทน return
        return;
      }

      final project = ProjectModel.create(
        title: nameController.text.trim(),
        iconKey: selectedIconKey!,
        userId: uid,
      ).copyWith(id: id);

      onSuccess?.call(project); // ✅ เรียก callback แทน return
      
    } catch (e) {
      debugPrint('createProject error: $e'); // ✅ แก้ไข error handling
      onError?.call(); // ✅ เรียก callback แทน return
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  void dispose() {
    nameController.dispose();
  }
}