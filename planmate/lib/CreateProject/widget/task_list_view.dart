import 'package:flutter/material.dart';
import 'package:planmate/CreateProject/widget/task_empty_state.dart';
import 'package:planmate/CreateProject/widget/task_item.dart';
import 'package:planmate/Models/task_model.dart';


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
    return _buildTasksList();
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade400,
            size: 48,
          ),
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade600,
            ),
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
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    // Group tasks by completion status
    final pendingTasks = tasks.where((task) => !task.isDone).toList();
    final completedTasks = tasks.where((task) => task.isDone).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task statistics
          _buildTaskStats(),
          const SizedBox(height: 20),

          // Pending tasks section
          if (pendingTasks.isNotEmpty) ...[
            _buildSectionHeader(
              'Pending Tasks',
              pendingTasks.length,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            ...pendingTasks.map((task) => _buildTaskItem(task)),
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
            ...completedTasks.map((task) => _buildTaskItem(task)),
          ],

          // Bottom padding
          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildTaskStats() {
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((task) => task.isDone).length;
    final overdueTasks = tasks.where((task) => task.isOverdue).length;
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFDDE67),
        // gradient: LinearGradient(
        //   colors: [
        //     const Color(0xFF8B5CF6).withOpacity(0.1),
        //     const Color(0xFF8B5CF6).withOpacity(0.05),
        //   ],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Task Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF030202),
                ),
              ),
              Text(
                '${(completionRate * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202430),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Progress bar
          LinearProgressIndicator(
            value: completionRate,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF202430)),
            minHeight: 6,
          ),
          const SizedBox(height: 16),
          
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', totalTasks, const Color(0xFF202430)),
              _buildStatItem('Completed', completedTasks, Color(0xFF202430)),
              if (overdueTasks > 0)
                _buildStatItem('Overdue', overdueTasks, Colors.red),
            ],
          ),
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
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

  Widget _buildTaskItem(TaskModel task) {
    final isTaskLoading = loadingTaskId == task.id;
    
    return TaskItem(
      task: task,
      isLoading: isTaskLoading,
      onToggle: () => onToggleTask?.call(task.id),
      onEdit: () => onEditTask?.call(task),
      onDelete: () => onDeleteTask?.call(task.id),
    );
  }
}