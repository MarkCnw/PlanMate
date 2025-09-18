import 'package:flutter/material.dart';
import 'package:planmate/CreateProject/Update/Presentation/update_task_screen.dart';
import 'package:planmate/CreateProject/widget/task_empty_state.dart';
import 'package:planmate/CreateProject/widget/task_item.dart';
import 'package:planmate/Models/task_model.dart';
import 'package:provider/provider.dart';
import 'package:planmate/provider/task_provider.dart';

class TaskListView extends StatelessWidget {
  final List<TaskModel> tasks;
  final bool isLoading;
  final String? error;
  final Function(String taskId)? onToggleTask;
  final Function(TaskModel task)? onEditTask;
  final Function(String taskId)? onDeleteTask;
  final VoidCallback? onRetry;
  final String? loadingTaskId; // ID ของ task ที่กำลัง loading

  const TaskListView({
    super.key,
    required this.tasks,
    this.isLoading = false,
    this.error,
    this.onToggleTask,
    this.onEditTask,
    this.onDeleteTask,
    this.onRetry,
    this.loadingTaskId,
  });

  @override
  Widget build(BuildContext context) {
    // Error state
    if (error != null) {
      return _buildErrorState();
    }

    // Loading state (initial loading)
    if (isLoading && tasks.isEmpty) {
      return _buildLoadingState();
    }

    // Empty state
    if (tasks.isEmpty) {
      return const EmptyTaskState();
    }

    // Tasks list
    return _buildTasksList(context);
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
          const SizedBox(height: 16),
          Text(
            'Failed to load tasks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error!,
            style: TextStyle(fontSize: 14, color: Colors.red.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading tasks...',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context) {
    // Group tasks by completion status
    final pendingTasks = tasks.where((task) => !task.isDone).toList();
    final completedTasks = tasks.where((task) => task.isDone).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task statistics
          const SizedBox(height: 20),

          // Pending tasks section
          if (pendingTasks.isNotEmpty) ...[
            _buildSectionHeader(
              'Pending Tasks',
              pendingTasks.length,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            ...pendingTasks.map((task) => _buildTaskItem(context, task)),
            const SizedBox(height: 20),
          ],

          // Completed tasks section
          if (completedTasks.isNotEmpty) ...[
            _buildSectionHeader(
              'Completed Tasks',
              completedTasks.length,
              Colors.green,
            ),
            const SizedBox(height: 12),
            ...completedTasks.map((task) => _buildTaskItem(context, task)),
          ],

          // Bottom padding
          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskModel task) {
    final isTaskLoading = loadingTaskId == task.id;
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return TaskItem(
      task: task,
      isLoading: isTaskLoading,
      // ✅ Connect to TaskProvider methods
      onToggle: () async {
        try {
          await taskProvider.toggleTaskComplete(task.id);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update task: $e'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },

      // ✅ Edit task callback
      onEdit: () {
        _openUpdateTaskSheet(context, task);
      },

      onDelete: () {
        _showDeleteConfirmation(context, task, taskProvider);
      },
    );
  }

  // ✅ Delete confirmation dialog
  void _showDeleteConfirmation(
    BuildContext context,
    TaskModel task,
    TaskProvider taskProvider, // รับ Provider เข้ามา
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            // ใช้ dialogContext ที่เป็นของ Dialog เอง
            title: const Text('Delete Task'),
            content: Text(
              'Are you sure you want to delete "${task.title}"?\n\nThis action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  // 1. ลบ Task โดยใช้ Provider
                  final success = await taskProvider.deleteTask(task.id);

                  // 2. ปิด Dialog และส่งผลลัพธ์กลับไป
                  Navigator.pop(dialogContext, success);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    // 3. จัดการแสดง SnackBar ข้างนอก Dialog
    if (context.mounted) {
      if (confirmed == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Task deleted successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
      } else if (confirmed == false && taskProvider.error != null) {
        // กรณีที่ deleteTask ล้มเหลว
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete task: ${taskProvider.error}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

void _openUpdateTaskSheet(BuildContext context, TaskModel task) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => UpdateTaskSheet(task: task),
  );
}
