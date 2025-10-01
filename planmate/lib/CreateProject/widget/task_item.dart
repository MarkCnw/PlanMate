import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:planmate/models/task_model.dart';
import 'package:provider/provider.dart';
import 'package:planmate/provider/task_provider.dart';

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

class _TaskItemState extends State<TaskItem>
    with TickerProviderStateMixin {
  late AnimationController _checkboxController;
  late AnimationController _slideController;
  late AnimationController _progressController;
  late Animation<double> _checkboxAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;

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
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.task.progress,
    ).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    // Set initial states
    if (widget.task.isDone) {
      _checkboxController.value = 1.0;
    }

    _progressController.forward();
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

    // Animate progress changes
    if (oldWidget.task.progress != widget.task.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.task.progress,
        end: widget.task.progress,
      ).animate(
        CurvedAnimation(
          parent: _progressController,
          curve: Curves.easeInOut,
        ),
      );

      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _checkboxController.dispose();
    _slideController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor();
    final borderColor =
        widget.task.isDone ? Colors.green.withOpacity(0.4) : priorityColor;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 1.5, // เพิ่มความหนาของกรอบ
          ),
          // boxShadow: [
          //   BoxShadow(
          //     color: priorityColor.withOpacity(0.1),
          //     blurRadius: 12,
          //     offset: const Offset(0, 4),
          //   ),
          // ],
        ),
        child: Column(
          children: [
            // Main content
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: widget.onEdit,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Square checkbox
                      _buildSquareCheckbox(),
                      const SizedBox(width: 16),

                      // Task content
                      Expanded(child: _buildTaskContent()),

                      // Action buttons
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),

            // Progress section (if task has progress)
            if (widget.task.hasProgress) _buildProgressSection(),
          ],
        ),
      ),
    );
  }

  // ✅ New square checkbox design
  Widget _buildSquareCheckbox() {
    final priorityColor = _getPriorityColor();

    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onToggle,
      child: AnimatedBuilder(
        animation: _checkboxAnimation,
        builder: (context, child) {
          return Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6), // มุมมน slightly
              border: Border.all(
                color: widget.task.isDone ? Colors.green : priorityColor,
                width: 2.5,
              ),
              color:
                  widget.task.isDone ? Colors.green : Colors.transparent,
            ),
            child:
                widget.isLoading
                    ? Padding(
                      padding: const EdgeInsets.all(6),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          priorityColor.withOpacity(0.6),
                        ),
                      ),
                    )
                    : widget.task.isDone
                    ? Transform.scale(
                      scale: _checkboxAnimation.value,
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      ),
                    )
                    : _buildStatusIcon(),
          );
        },
      ),
    );
  }

  Widget _buildStatusIcon() {
    return const SizedBox.shrink();
  }

  Widget _buildTaskContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Task title with status badge
        Row(
          children: [
            Expanded(
              child: Text(
                widget.task.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      widget.task.isDone
                          ? Colors.grey.shade500
                          : Colors.grey.shade800,
                  decoration:
                      widget.task.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        // Description if exists
        if (widget.task.hasDescription) ...[
          const SizedBox(height: 4),
          Text(
            widget.task.description!,
            style: TextStyle(
              fontSize: 14,
              color:
                  widget.task.isDone
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
              decoration:
                  widget.task.isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        // Task metadata
        const SizedBox(height: 12),
        _buildTaskMetadata(),
      ],
    );
  }

  Widget _buildTaskMetadata() {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        // Due date
        if (widget.task.hasDueDate)
          _buildMetadataItem(
            Icons.schedule,
            _formatDueDate(widget.task.dueDate!),
            _getDueDateColor(),
          ),

        // Progress percentage
        if (widget.task.hasProgress && !widget.task.isDone)
          _buildMetadataItem(
            Icons.trending_up,
            widget.task.progressText,
            _getProgressColor(),
          ),

        // Priority indicator
        _buildMetadataItem(
          Icons.flag,
          _getPriorityText(),
          _getPriorityColor(),
        ),
      ],
    );
  }

  Widget _buildMetadataItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            widget.onEdit?.call();
            break;
          case 'delete':
            _showDeleteConfirmation();
            break;
          case 'progress':
            _showProgressDialog();
            break;
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      color: Colors.white,
      elevation: 8,
      itemBuilder: (context) {
        List<PopupMenuEntry<String>> items = [];

        // Progress update (เฉพาะถ้า task ยังไม่เสร็จ)
        if (!widget.task.isDone) {
          items.add(
            PopupMenuItem(
              value: 'progress',
              child: Row(
                children: [
                  _menuIcon(Icons.trending_up, Colors.blue),
                  const SizedBox(width: 12),
                  const Text(
                    'Update Progress',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Edit
        items.add(
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                _menuIcon(Icons.edit, Colors.indigo),
                const SizedBox(width: 12),
                const Text(
                  'Edit Task',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );

        // Delete
        items.add(
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                _menuIcon(Icons.delete, Colors.red),
                const SizedBox(width: 12),
                const Text(
                  'Delete Task',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        );

        return items;
      },

      // ปุ่มเรียกเมนู (modern ellipsis button)
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          FontAwesomeIcons.ellipsisVertical, // ใช้จุดแนวตั้งแบบ modern
          size: 18,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  /// helper สำหรับไอคอนในเมนู
  Widget _menuIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Progress information row
          Row(
            children: [
              // Progress percentage
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getProgressColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.task.progressText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(),
                  ),
                ),
              ),

              const Spacer(),

              // Quick progress actions (if not completed)
              if (!widget.task.isDone && widget.task.hasProgress)
                _buildQuickProgressButtons(),
            ],
          ),

          // Progress bar
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _progressAnimation,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            builder: (context, child) {
              return Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getProgressColor(),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: _getProgressColor().withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickProgressButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildQuickProgressButton('+25%', 0.25),
        const SizedBox(width: 4),
        _buildQuickProgressButton('Done', 1.0 - widget.task.progress),
      ],
    );
  }

  Widget _buildQuickProgressButton(String label, double increment) {
    return GestureDetector(
      onTap: () async {
        final newProgress = (widget.task.progress + increment).clamp(
          0.0,
          1.0,
        );
        final taskProvider = context.read<TaskProvider>();
        await _handleUpdateProgress(taskProvider, newProgress);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  // ===== Action Handlers =====

  Future<void> _handleUpdateProgress(
    TaskProvider taskProvider,
    double progress,
  ) async {
    try {
      final success = await taskProvider.updateTaskProgress(
        taskId: widget.task.id,
        progress: progress,
      );
      if (!success && mounted) {
        _showErrorSnackBar('Failed to update progress');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error updating progress: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===== Color Helper Methods =====

  // ✅ Updated priority color method
  Color _getPriorityColor() {
    switch (widget.task.priority) {
      case 1:
        return Colors.red.shade600; // High priority - แดงเข้ม
      case 2:
        return Colors.orange.shade600; // Medium priority - ส้มเข้ม
      case 3:
        return Colors.green.shade600; // Low priority - เขียวเข้ม
      default:
        return Colors.grey.shade500; // Default - เทา
    }
  }

  // ✅ New helper method for priority text
  String _getPriorityText() {
    switch (widget.task.priority) {
      case 1:
        return 'High';
      case 2:
        return 'Medium';
      case 3:
        return 'Low';
      default:
        return 'Normal';
    }
  }

  Color _getStatusColor() {
    switch (widget.task.status) {
      case TaskStatus.inProgress:
        return _getPriorityColor();
      case TaskStatus.completed:
        return Colors.green;
      default:
        return _getPriorityColor();
    }
  }

  Color _getProgressColor() {
    final progress = widget.task.progress;
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.7) return Colors.blue;
    if (progress >= 0.3) return Colors.orange;
    return Colors.red;
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
      builder:
          (context) => AlertDialog(
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

  void _showProgressDialog() {
    double tempProgress = widget.task.progress;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Update Progress'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Current: ${widget.task.progressText}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'New: ${(tempProgress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: tempProgress,
                        min: 0.0,
                        max: 1.0,
                        divisions: 20,
                        onChanged: (value) {
                          setDialogState(() {
                            tempProgress = value;
                          });
                        },
                      ),
                      // Quick buttons
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildDialogProgressButton(
                            '25%',
                            0.25,
                            tempProgress,
                            setDialogState,
                          ),
                          _buildDialogProgressButton(
                            '50%',
                            0.5,
                            tempProgress,
                            setDialogState,
                          ),
                          _buildDialogProgressButton(
                            '75%',
                            0.75,
                            tempProgress,
                            setDialogState,
                          ),
                          _buildDialogProgressButton(
                            '100%',
                            1.0,
                            tempProgress,
                            setDialogState,
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final taskProvider = context.read<TaskProvider>();
                        await _handleUpdateProgress(
                          taskProvider,
                          tempProgress,
                        );
                      },
                      child: const Text('Update'),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildDialogProgressButton(
    String label,
    double value,
    double currentValue,
    StateSetter setDialogState,
  ) {
    final isSelected = (currentValue - value).abs() < 0.01;

    return GestureDetector(
      onTap: () => setDialogState(() => currentValue = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
