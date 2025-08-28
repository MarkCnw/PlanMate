import 'package:flutter/material.dart';
import 'package:planmate/provider/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:planmate/Models/task_model.dart';

class CreateTaskController {
  final BuildContext context;
  final String projectId;
  final VoidCallback onStateChanged;
  final void Function(TaskModel task)? onSuccess;
  final VoidCallback? onError;

  CreateTaskController({
    required this.context,
    required this.projectId,
    required this.onStateChanged,
    this.onSuccess,
    this.onError,
  });

  // Form controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Form state
  DateTime? selectedDueDate;
  int selectedPriority = 2; // Default: Medium
  bool isLoading = false;

  // Validation errors
  String? titleError;
  String? descriptionError;
  String? dueDateError;

  // Priority options
  final List<Map<String, dynamic>> priorityOptions = [
    {'value': 1, 'label': 'High', 'color': Colors.red},
    {'value': 2, 'label': 'Medium', 'color': Colors.orange},
    {'value': 3, 'label': 'Low', 'color': Colors.green},
  ];

  // Get current priority info
  Map<String, dynamic> get currentPriorityInfo {
    return priorityOptions.firstWhere(
      (option) => option['value'] == selectedPriority,
      orElse: () => priorityOptions[1], // Default to Medium
    );
  }

  // Select priority
  void selectPriority(int priority) {
    selectedPriority = priority;
    onStateChanged();
  }

  // Select due date
  void selectDueDate(DateTime? date) {
    selectedDueDate = date;
    dueDateError = null;
    onStateChanged();
  }

  // Clear due date
  void clearDueDate() {
    selectedDueDate = null;
    dueDateError = null;
    onStateChanged();
  }

  // Clear title error
  void clearTitleError() {
    titleError = null;
    onStateChanged();
  }

  // Clear description error
  void clearDescriptionError() {
    descriptionError = null;
    onStateChanged();
  }

  // Validate form
  bool validateForm() {
    titleError = null;
    descriptionError = null;
    dueDateError = null;

    bool isValid = true;

    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    // Validate title
    if (title.isEmpty) {
      titleError = 'Task title is required';
      isValid = false;
    } else if (title.length > 100) {
      titleError = 'Task title is too long (max 100 characters)';
      isValid = false;
    }

    // Validate description
    if (description.isNotEmpty && description.length > 500) {
      descriptionError = 'Description is too long (max 500 characters)';
      isValid = false;
    }

    // Validate due date (optional validation if needed)
    if (selectedDueDate != null) {
      final now = DateTime.now();
      if (selectedDueDate!.isBefore(DateTime(now.year, now.month, now.day))) {
        dueDateError = 'Due date cannot be in the past';
        isValid = false;
      }
    }

    onStateChanged();
    return isValid;
  }

  // Create task
  Future<void> createTask() async {
    if (!validateForm()) return;

    isLoading = true;
    onStateChanged();

    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      final title = titleController.text.trim();
      final description = descriptionController.text.trim();

      final taskId = await taskProvider.createTask(
        title: title,
        projectId: projectId,
        description: description.isEmpty ? null : description,
        dueDate: selectedDueDate,
        priority: selectedPriority,
      );

      if (taskId == null) {
        // Error is already set in TaskProvider
        onError?.call();
        return;
      }

      // Create task model for success callback
      final task = TaskModel.create(
        title: title,
        projectId: projectId,
        userId: taskProvider.currentUserId!,
        description: description.isEmpty ? null : description,
        dueDate: selectedDueDate,
        priority: selectedPriority,
      ).copyWith(id: taskId);

      onSuccess?.call(task);

    } catch (e) {
      debugPrint('createTask error: $e');
      onError?.call();
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // Reset form
  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    selectedDueDate = null;
    selectedPriority = 2;
    titleError = null;
    descriptionError = null;
    dueDateError = null;
    onStateChanged();
  }

  // Format date for display
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Today';
    } else if (targetDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Get due date display text
  String? get dueDateDisplayText {
    if (selectedDueDate == null) return null;
    return formatDate(selectedDueDate!);
  }

  // Check if form has changes
  bool get hasChanges {
    return titleController.text.trim().isNotEmpty ||
           descriptionController.text.trim().isNotEmpty ||
           selectedDueDate != null ||
           selectedPriority != 2;
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
  }
}