import 'dart:math';

import 'package:flutter/material.dart';
import 'package:planmate/Auth/services/google_service.dart';
import 'package:planmate/Models/project_model.dart';
import 'package:planmate/Services/firebase_project_service.dart';

class CreateProjectController {
  final VoidCallback onStateChanged;
  final void Function(String name, String iconPath)? onSubmit;

  CreateProjectController({required this.onStateChanged, this.onSubmit});

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

  Future<ProjectModel?> createProject() async {
    final uid = _firebaseServices.getCurrentUser()?.uid;
    if (uid == null) return null;
    if (!validateForm()) return null;

    isLoading = true;
    onStateChanged();
    try {
      final id = await _projectService.createProject(
        title: nameController.text.trim(),
        iconKey: selectedIconKey!,
        description: null,
      );
      if (id.isEmpty) return null;

      final project = ProjectModel.create(
        title: nameController.text.trim(),
        iconKey: selectedIconKey!,
        userId: uid,
      ).copyWith(id: id);

      onSubmit?.call(
        nameController.text.trim(),
        iconOptionsMap[selectedIconKey!]!.iconPath,
      );
      return project;
    } catch (_) {
        debugPrint('createProject error: $e\n$st');
      return null;
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  void dispose() {
    nameController.dispose();
  }
}

class IconDataModel {
  final String iconPath;
  final int colorValue;

  IconDataModel({required this.iconPath, required this.colorValue});

  Color get color => Color(colorValue);
}
