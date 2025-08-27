import 'package:flutter/material.dart';
import 'package:planmate/provider/auth_provider.dart';
import 'package:planmate/provider/project_provider.dart';
import 'package:provider/provider.dart';
import 'package:planmate/Models/project_model.dart';


class CreateProjectController {
  final BuildContext context;
  final VoidCallback onStateChanged;
  final void Function(ProjectModel project)? onSuccess;
  final VoidCallback? onError;

  CreateProjectController({
    required this.context,
    required this.onStateChanged,
    this.onSuccess,
    this.onError,
  });

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

  Future<void> createProject() async {
    if (!validateForm()) return;

    isLoading = true;
    onStateChanged();
    
    try {
      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      
      final projectId = await projectProvider.createProject(
        title: nameController.text.trim(),
        iconKey: selectedIconKey!,
        description: null,
      );
      
      if (projectId == null) {
        // Error is already set in ProjectProvider
        onError?.call();
        return;
      }

      // Create project model for success callback
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final project = ProjectModel.create(
        title: nameController.text.trim(),
        iconKey: selectedIconKey!,
        userId: authProvider.userId!,
      ).copyWith(id: projectId);

      onSuccess?.call(project);
      
    } catch (e) {
      debugPrint('createProject error: $e');
      onError?.call();
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  void dispose() {
    nameController.dispose();
  }
}