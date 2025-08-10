import 'package:flutter/material.dart';
import 'package:planmate/Models/project_model.dart';
import 'package:planmate/Services/firebase_project_service.dart';

class UpdateProjectController {
  final ProjectModel project;
  final VoidCallback onStateChanged;

  UpdateProjectController({
    required this.project,
    required this.onStateChanged,
  }) {
    nameController.text = project.title;
    selectedIconKey = project.iconKey;
    selectedIconPath = project.iconPath;
  }

  final FirebaseProjectServices _projectService = FirebaseProjectServices();

  final TextEditingController nameController = TextEditingController();

  List<Map<String, String>> iconOptions = [
    {'key': 'arrow', 'path': 'assets/icons/arrow.png'},
    {'key': 'book', 'path': 'assets/icons/book.png'},
    {'key': 'check', 'path': 'assets/icons/check.png'},
    {'key': 'check&cal', 'path': 'assets/icons/check&cal.png'},
    {'key': 'Chess', 'path': 'assets/icons/Chess.png'},
    {'key': 'computer', 'path': 'assets/icons/computer.png'},
    {'key': 'crayons', 'path': 'assets/icons/crayons.png'},
    {'key': 'Egg&Bacon', 'path': 'assets/icons/Egg&Bacon.png'},
    {'key': 'esports', 'path': 'assets/icons/esports.png'},
    {'key': 'Football', 'path': 'assets/icons/Football.png'},
    {'key': 'Gymming', 'path': 'assets/icons/Gymming.png'},
    {'key': 'pencil', 'path': 'assets/icons/pencil.png'},
    {'key': 'Pizza', 'path': 'assets/icons/Pizza.png'},
    {'key': 'rocket', 'path': 'assets/icons/rocket.png'},
    {'key': 'ruler', 'path': 'assets/icons/ruler.png'},
  ];

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

    if (name.isEmpty) {
      nameError = 'Project name is required';
    } else {
      nameError = null;
    }

    if (selectedIconPath == null) {
      iconError = 'Icon selection is required';
    } else {
      iconError = null;
    }

    if (nameError != null || iconError != null) {
      onStateChanged();
      return;
    }

    isLoading = true;
    onStateChanged();

    try {
      await _projectService.updateProject(
        projectId: project.id,
        newTitle: name,
        newIconKey: selectedIconKey!,
        newIconPath: selectedIconPath!,
      );
      // อาจจะมี callback แจ้ง UI ว่า update สำเร็จ
    } catch (e) {
      // handle error (optional)
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  void dispose() {
    nameController.dispose();
  }
}
