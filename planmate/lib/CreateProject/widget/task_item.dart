import 'package:flutter/material.dart';
import 'package:planmate/Models/task_model.dart';

class TaskItem extends StatefulWidget {
  final TaskModel task;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isLoading;

  const TaskItem({
    super.key,
    required this.task,
    this.onToggle,
    this.onEdit,
    this.onDelete,
    this.isLoading = false,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> with TickerProviderStateMixin {
  late AnimationController _checkboxController;
  late AnimationController _slideController;
  late Animation<double> _checkboxAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Checkbox animation
    _checkboxController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _checkboxAnimation = CurvedAnimation(
      parent: _checkboxController,
      curve: Curves.elasticOut,
    );

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Set initial state
    if (widget.task.isDone) {
      _checkboxController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate checkbox when status changes
    if (oldWidget.task.isDone != widget.task.isDone) {
      if (widget.task.isDone) {
        _checkboxController.forward();
        _slideController.forward().then((_) {
          _slideController.reverse();
        });
      } else {
        _checkboxController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _checkboxController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.task.isDone
                ? Colors.green.withOpacity(0.3)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onEdit,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Custom checkbox
                  _buildCustomCheckbox(),
                  const SizedBox(width: 16),
                  
                  // Task content
                  Expanded(
                    child: _buildTaskContent(),
                  ),
                  
                  // Priority indicator
                  _buildPriorityIndicator(),
                  
                  const SizedBox(width: 8),
                  
                  // More options
                  _buildMoreOptions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomCheckbox() {
    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onToggle,
      child: AnimatedBuilder(
        animation: _checkboxAnimation,
        builder: (context, child) {
          return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.task.isDone
                    ? Colors.green
                    : Colors.grey.shade400,
                width: 2,
              ),
              color: widget.task.isDone
                  ? Colors.green
                  : Colors.transparent,
            ),
            child: widget.isLoading
                ? Padding(
                    padding: const EdgeInsets.all(4),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey.shade400,
                      ),
                    ),
                  )
                : widget.task.isDone
                    ? Transform.scale(
                        scale: _checkboxAnimation.value,
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      )
                    : null,
          );
        },
      ),
    );
  }

  Widget _buildTaskContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Task title
        Text(
          widget.task.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: widget.task.isDone
                ? Colors.grey.shade500
                : Colors.grey.shade800,
            decoration: widget.task.isDone
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        // Description if exists
        if (widget.task.hasDescription) ...[
          const SizedBox(height: 4),
          Text(
            widget.task.description!,
            style: TextStyle(
              fontSize: 14,
              color: widget.task.isDone
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
              decoration: widget.task.isDone
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        
        // Due date and status info
        const SizedBox(height: 8),
        _buildTaskInfo(),
      ],
    );
  }

  Widget _buildTaskInfo() {
    return Row(
      children: [
        // Due date
        if (widget.task.hasDueDate) ...[
          Icon(
            Icons.schedule,
            size: 14,
            color: _getDueDateColor(),
          ),
          const SizedBox(width: 4),
          Text(
            _formatDueDate(widget.task.dueDate!),
            style: TextStyle(
              fontSize: 12,
              color: _getDueDateColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
        ],
        
        // Completion status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: widget.task.isDone
                ? Colors.green.withOpacity(0.1)
                : Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.task.statusText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: widget.task.isDone ? Colors.green : Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityIndicator() {
    final priorityColor = _getPriorityColor();
    
    return Container(
      width: 4,
      height: 40,
      decoration: BoxDecoration(
        color: priorityColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildMoreOptions() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            widget.onEdit?.call();
            break;
          case 'delete':
            _showDeleteConfirmation();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18, color: Colors.blue),
              SizedBox(width: 12),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.more_vert,
          size: 16,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    switch (widget.task.priority) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.green;
      default: return Colors.orange;
    }
  }

  Color _getDueDateColor() {
    if (widget.task.isDone) return Colors.grey.shade400;
    if (widget.task.isOverdue) return Colors.red;
    if (widget.task.isDueToday) return Colors.orange;
    return Colors.grey.shade600;
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Today';
    } else if (targetDate == tomorrow) {
      return 'Tomorrow';
    } else if (targetDate.isBefore(today)) {
      return 'Overdue';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text(
          'Are you sure you want to delete "${widget.task.title}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}