import 'package:flutter/material.dart';
import 'package:planmate/provider/project_provider.dart';
import 'package:provider/provider.dart';
import 'package:planmate/Models/project_model.dart';


class UpdateProjectController {
  final BuildContext context;
  final ProjectModel project;
  final VoidCallback onStateChanged;
  final VoidCallback? onSuccess;

  UpdateProjectController({
    required this.context,
    required this.project,
    required this.onStateChanged,
    this.onSuccess,
  }) {
    nameController.text = project.title;
    selectedIconKey = project.iconKey;
    selectedIconPath = project.iconPath;
  }

  final TextEditingController nameController = TextEditingController();

  // Use data from ProjectModel instead of hardcode
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

  Future<void> updateProject() async {
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

    // Check if there are changes
    bool hasChanges = name != project.title || selectedIconKey != project.iconKey;
    if (!hasChanges && nameError == null && iconError == null) {
      // No changes but successful validation - close modal
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
      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      
      final success = await projectProvider.updateProject(
        projectId: project.id,
        newTitle: name,
        newIconKey: selectedIconKey!,
      );

      if (success) {
        debugPrint('✅ Project updated successfully');
        onSuccess?.call();
      } else {
        debugPrint('❌ Failed to update project: ${projectProvider.error}');
        // Error is already set in ProjectProvider
      }

    } catch (e) {
      debugPrint('❌ Failed to update project: $e');
      // ProjectProvider handles error setting
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  void dispose() {
    nameController.dispose();
  }
}