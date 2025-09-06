import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController hoursController = TextEditingController();
  final TextEditingController minutesController = TextEditingController();

  // Form state
  DateTime? selectedDueDate;
  int selectedPriority = 2; // Default: Medium
  Duration? estimatedDuration;
  double initialProgress = 0.0;
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

  // ✅ Time estimation methods
  void calculateEstimatedTime() {
    final hours = int.tryParse(hoursController.text) ?? 0;
    final minutes = int.tryParse(minutesController.text) ?? 0;
    
    if (hours > 0 || minutes > 0) {
      estimatedDuration = Duration(hours: hours, minutes: minutes);
    } else {
      estimatedDuration = null;
    }
    onStateChanged();
  }

  void setQuickTime(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    
    hoursController.text = hours > 0 ? hours.toString() : '';
    minutesController.text = minutes > 0 ? minutes.toString() : '';
    
    calculateEstimatedTime();
  }

  String get estimatedTimeText {
    if (estimatedDuration == null) return 'No estimate';
    final hours = estimatedDuration!.inHours;
    final minutes = estimatedDuration!.inMinutes % 60;
    
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  // ✅ Progress methods
  void setInitialProgress(double progress) {
    initialProgress = progress.clamp(0.0, 1.0);
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

    // Validate time estimation (optional but should be reasonable)
    if (estimatedDuration != null) {
      if (estimatedDuration!.inMinutes > 24 * 60) {
        // More than 24 hours might be unrealistic for a single task
        debugPrint('⚠️ Estimated time is more than 24 hours');
      }
    }

    onStateChanged();
    return isValid;
  }

  // Create task with enhanced features
  Future<void> createTask() async {
    if (!validateForm()) return;

    isLoading = true;
    onStateChanged();

    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      final title = titleController.text.trim();
      final description = descriptionController.text.trim();

      // ✅ สร้าง task พร้อม time estimation และ initial progress
      final taskId = await taskProvider.createTaskEnhanced(
        title: title,
        projectId: projectId,
        description: description.isEmpty ? null : description,
        dueDate: selectedDueDate,
        priority: selectedPriority,
        estimatedDuration: estimatedDuration,
        initialProgress: initialProgress,
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
        estimatedDuration: estimatedDuration,
      ).copyWith(
        id: taskId,
        progress: initialProgress,
        status: initialProgress > 0 ? TaskStatus.inProgress : TaskStatus.pending,
        startedAt: initialProgress > 0 ? DateTime.now() : null,
      );

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
    hoursController.clear();
    minutesController.clear();
    selectedDueDate = null;
    selectedPriority = 2;
    estimatedDuration = null;
    initialProgress = 0.0;
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
           selectedPriority != 2 ||
           estimatedDuration != null ||
           initialProgress > 0.0;
  }

  // ✅ Helper methods for UI
  String getProgressText() {
    return '${(initialProgress * 100).round()}%';
  }

  Color getProgressColor() {
    if (initialProgress == 0.0) return Colors.grey.shade400;
    if (initialProgress < 0.3) return Colors.red;
    if (initialProgress < 0.7) return Colors.orange;
    if (initialProgress < 1.0) return Colors.blue;
    return Colors.green;
  }

  String getProgressStatusText() {
    if (initialProgress == 0.0) return 'Not started';
    if (initialProgress < 1.0) return 'In progress';
    return 'Completed';
  }

  // ✅ Validation helpers
  bool get hasValidTimeEstimation {
    return estimatedDuration != null && estimatedDuration!.inMinutes > 0;
  }

  bool get isReasonableTimeEstimate {
    if (estimatedDuration == null) return true;
    return estimatedDuration!.inMinutes <= 24 * 60; // Max 24 hours
  }

  // ✅ Quick actions for common scenarios
  void setQuickTask() {
    // Quick 30-minute task
    setQuickTime(30);
    setInitialProgress(0.0);
    selectedPriority = 2; // Medium priority
    onStateChanged();
  }

  void setUrgentTask() {
    // Urgent task due today
    selectedDueDate = DateTime.now().add(const Duration(hours: 4));
    selectedPriority = 1; // High priority
    onStateChanged();
  }

  void setLongTermTask() {
    // Long-term project task
    setQuickTime(240); // 4 hours
    selectedDueDate = DateTime.now().add(const Duration(days: 7));
    selectedPriority = 3; // Low priority
    onStateChanged();
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    hoursController.dispose();
    minutesController.dispose();
  }
}

// ✅ Extension สำหรับ TaskProvider เพื่อรองรับ enhanced features
extension TaskProviderEnhanced on TaskProvider {
  Future<String?> createTaskEnhanced({
    required String title,
    required String projectId,
    String? description,
    DateTime? dueDate,
    int priority = 2,
    Duration? estimatedDuration,
    double initialProgress = 0.0,
  }) async {
    try {
      debugPrint('🔄 Creating enhanced task for project: $projectId');
      debugPrint('📊 Initial progress: ${(initialProgress * 100).round()}%');
      debugPrint('⏱️ Estimated duration: $estimatedDuration');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // สร้าง task พื้นฐานก่อน
      final taskId = await createTask(
        title: title,
        projectId: projectId,
        description: description,
        dueDate: dueDate,
        priority: priority,
      );

      if (taskId == null) return null;

      // อัปเดตด้วยข้อมูลเพิ่มเติม
      if (estimatedDuration != null || initialProgress > 0.0) {
        await updateTaskEnhanced(
          taskId: taskId,
          estimatedDuration: estimatedDuration,
          progress: initialProgress,
        );
      }

      debugPrint('✅ Enhanced task created successfully');
      return taskId;
    } catch (e) {
      debugPrint('❌ Failed to create enhanced task: $e');
      return null;
    }
  }

  Future<bool> updateTaskEnhanced({
    required String taskId,
    Duration? estimatedDuration,
    double? progress,
  }) async {
    try {
      // อัปเดตข้อมูลเพิ่มเติมใน Firestore
      final updateData = <String, dynamic>{};
      
      if (estimatedDuration != null) {
        updateData['estimatedDuration'] = estimatedDuration.inMinutes;
      }
      
      if (progress != null) {
        updateData['progress'] = progress.clamp(0.0, 1.0);
        if (progress > 0.0 && progress < 1.0) {
          updateData['status'] = 'in_progress';
          updateData['startedAt'] = FieldValue.serverTimestamp();
        } else if (progress >= 1.0) {
          updateData['status'] = 'completed';
          updateData['isDone'] = true;
          updateData['completedAt'] = FieldValue.serverTimestamp();
        }
      }

      if (updateData.isNotEmpty) {
        updateData['updatedAt'] = FieldValue.serverTimestamp();
        
        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(taskId)
            .update(updateData);
      }

      return true;
    } catch (e) {
      debugPrint('❌ Failed to update enhanced task: $e');
      return false;
    }
  }
}