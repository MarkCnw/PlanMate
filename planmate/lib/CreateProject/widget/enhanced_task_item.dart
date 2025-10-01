import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:planmate/models/task_model.dart';
import 'package:provider/provider.dart';
import 'package:planmate/provider/task_provider.dart';

class EnhancedTaskItem extends StatefulWidget {
  final TaskModel task;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isLoading;

  const EnhancedTaskItem({
    super.key,
    required this.task,
    this.onToggle,
    this.onEdit,
    this.onDelete,
    this.isLoading = false,
  });

  @override
  State<EnhancedTaskItem> createState() => _EnhancedTaskItemState();
}

class _EnhancedTaskItemState extends State<EnhancedTaskItem>
    with TickerProviderStateMixin {
  late AnimationController _checkboxController;
  late AnimationController _slideController;
  late AnimationController _progressController;
  late AnimationController _glowController;
  late Animation<double> _checkboxAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _checkboxController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _checkboxAnimation = CurvedAnimation(
      parent: _checkboxController,
      curve: Curves.elasticOut,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, 0),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.task.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    ));

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.task.isDone) {
      _checkboxController.value = 1.0;
      _glowController.repeat(reverse: true);
    }

    _progressController.forward();
  }

  @override
  void didUpdateWidget(EnhancedTaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.task.isDone != widget.task.isDone) {
      if (widget.task.isDone) {
        _checkboxController.forward();
        _glowController.repeat(reverse: true);
        _slideController.forward().then((_) => _slideController.reverse());
      } else {
        _checkboxController.reverse();
        _glowController.reset();
      }
    }

    if (oldWidget.task.progress != widget.task.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.task.progress,
        end: widget.task.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOutCubic,
      ));
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _checkboxController.dispose();
    _slideController.dispose();
    _progressController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Stack(
          children: [
            // Glow effect for completed tasks
            if (widget.task.isDone)
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3 * _glowAnimation.value),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildMainCard(),
                ),
              )
            else
              _buildMainCard(),

            // Priority indicator stripe
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 5,
                decoration: BoxDecoration(
                  color: _getPriorityColor(),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
            ),

            // Due date indicator (if overdue)
            if (widget.task.isOverdue && !widget.task.isDone)
              Positioned(
                right: 16,
                top: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, size: 12, color: Colors.red.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'OVERDUE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.task.isDone 
            ? Colors.green.withOpacity(0.3)
            : _getPriorityColor().withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: _getPriorityColor().withOpacity(0.05),
            blurRadius: 25,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.onEdit,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildEnhancedCheckbox(),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTaskContent()),
                    _buildActionMenu(),
                  ],
                ),
                if (widget.task.hasProgress || widget.task.hasDescription)
                  const SizedBox(height: 16),
                if (widget.task.hasProgress) _buildProgressSection(),
                if (widget.task.hasDescription) ...[
                  const SizedBox(height: 12),
                  _buildDescription(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedCheckbox() {
    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onToggle,
      child: AnimatedBuilder(
        animation: _checkboxAnimation,
        builder: (context, child) {
          return Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.task.isDone ? Colors.green : _getPriorityColor(),
                width: 3,
              ),
              color: widget.task.isDone 
                ? Colors.green 
                : Colors.transparent,
              gradient: widget.task.isDone
                ? const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            ),
            child: widget.isLoading
              ? Padding(
                  padding: const EdgeInsets.all(6),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getPriorityColor().withOpacity(0.7),
                    ),
                  ),
                )
              : widget.task.isDone
                ? Transform.scale(
                    scale: _checkboxAnimation.value,
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                : _buildStatusIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator() {
    if (widget.task.progress == 0) {
      return Icon(
        Icons.radio_button_unchecked,
        color: _getPriorityColor().withOpacity(0.3),
        size: 16,
      );
    }
    
    return Center(
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: _getProgressColor(),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildTaskContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Task title with status
        Row(
          children: [
            Expanded(
              child: Text(
                widget.task.title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: widget.task.isDone
                    ? Colors.grey.shade500
                    : const Color(0xFF1A202C),
                  decoration: widget.task.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                  letterSpacing: 0.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Status badge
            _buildStatusBadge(),
          ],
        ),

        const SizedBox(height: 8),

        // Task metadata chips
        _buildMetadataChips(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    if (widget.task.isDone) {
      backgroundColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      text = 'DONE';
      icon = Icons.check_circle_rounded;
    } else if (widget.task.progress > 0) {
      backgroundColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
      text = 'IN PROGRESS';
      icon = Icons.trending_up_rounded;
    } else if (widget.task.isOverdue) {
      backgroundColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      text = 'OVERDUE';
      icon = Icons.warning_rounded;
    } else {
      backgroundColor = Colors.grey.shade100;
      textColor = Colors.grey.shade600;
      text = 'TODO';
      icon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        // Due date chip
        if (widget.task.hasDueDate)
          _buildMetadataChip(
            icon: Icons.calendar_today_rounded,
            text: _formatDueDate(widget.task.dueDate!),
            color: _getDueDateColor(),
            backgroundColor: _getDueDateColor().withOpacity(0.1),
          ),

        // Priority chip
        _buildMetadataChip(
          icon: _getPriorityIcon(),
          text: _getPriorityText(),
          color: _getPriorityColor(),
          backgroundColor: _getPriorityColor().withOpacity(0.1),
        ),

        // Progress chip (if in progress)
        if (widget.task.hasProgress && !widget.task.isDone)
          _buildMetadataChip(
            icon: Icons.trending_up_rounded,
            text: widget.task.progressText,
            color: _getProgressColor(),
            backgroundColor: _getProgressColor().withOpacity(0.1),
          ),
      ],
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String text,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        widget.task.description!,
        style: TextStyle(
          fontSize: 14,
          color: widget.task.isDone 
            ? Colors.grey.shade500
            : Colors.grey.shade700,
          height: 1.4,
          decoration: widget.task.isDone 
            ? TextDecoration.lineThrough 
            : TextDecoration.none,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getProgressColor().withOpacity(0.05),
            _getProgressColor().withOpacity(0.02),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _getProgressColor().withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          // Progress header
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                size: 16,
                color: _getProgressColor(),
              ),
              const SizedBox(width: 8),
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getProgressColor(),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getProgressColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.task.progressText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) => Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getProgressColor(),
                        _getProgressColor().withOpacity(0.8),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(4),
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
            ),
          ),

          // Quick action buttons for non-completed tasks
          if (!widget.task.isDone && widget.task.hasProgress) ...[
            const SizedBox(height: 12),
            _buildQuickActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        const Text(
          'Quick update:',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        _buildQuickActionButton('+25%', 0.25),
        const SizedBox(width: 8),
        _buildQuickActionButton('Complete', 1.0 - widget.task.progress),
      ],
    );
  }

  Widget _buildQuickActionButton(String label, double increment) {
    return GestureDetector(
      onTap: () async {
        final newProgress = (widget.task.progress + increment).clamp(0.0, 1.0);
        final taskProvider = context.read<TaskProvider>();
        await taskProvider.updateTaskProgress(
          taskId: widget.task.id,
          progress: newProgress,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getProgressColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getProgressColor().withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _getProgressColor(),
          ),
        ),
      ),
    );
  }

  Widget _buildActionMenu() {
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 12,
      itemBuilder: (context) {
        return [
          if (!widget.task.isDone)
            PopupMenuItem(
              value: 'progress',
              child: _buildMenuItem(
                Icons.trending_up_rounded,
                'Update Progress',
                Colors.blue,
              ),
            ),
          PopupMenuItem(
            value: 'edit',
            child: _buildMenuItem(
              Icons.edit_rounded,
              'Edit Task',
              Colors.indigo,
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: _buildMenuItem(
              Icons.delete_rounded,
              'Delete Task',
              Colors.red,
            ),
          ),
        ];
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(
          Icons.more_vert_rounded,
          size: 18,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: text == 'Delete Task' ? color : Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  // Helper methods
  Color _getPriorityColor() {
    switch (widget.task.priority) {
      case 1: return const Color(0xFFE53E3E); // High - Red
      case 2: return const Color(0xFFFF8C00); // Medium - Orange  
      case 3: return const Color(0xFF38A169); // Low - Green
      default: return Colors.grey.shade500;
    }
  }

  IconData _getPriorityIcon() {
    switch (widget.task.priority) {
      case 1: return Icons.keyboard_double_arrow_up_rounded;
      case 2: return Icons.keyboard_arrow_up_rounded;
      case 3: return Icons.keyboard_arrow_down_rounded;
      default: return Icons.remove_rounded;
    }
  }

  String _getPriorityText() {
    switch (widget.task.priority) {
      case 1: return 'High Priority';
      case 2: return 'Medium Priority';
      case 3: return 'Low Priority';
      default: return 'Normal';
    }
  }

  Color _getProgressColor() {
    final progress = widget.task.progress;
    if (progress >= 1.0) return const Color(0xFF38A169); // Green
    if (progress >= 0.7) return const Color(0xFF3182CE); // Blue
    if (progress >= 0.3) return const Color(0xFFED8936); // Orange
    return const Color(0xFFE53E3E); // Red
  }

  Color _getDueDateColor() {
    if (widget.task.isDone) return Colors.grey.shade400;
    if (widget.task.isOverdue) return const Color(0xFFE53E3E);
    if (widget.task.isDueToday) return const Color(0xFFED8936);
    return Colors.grey.shade600;
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Due Today';
    } else if (targetDate == tomorrow) {
      return 'Due Tomorrow';
    } else if (targetDate.isBefore(today)) {
      return 'Overdue';
    } else {
      final difference = targetDate.difference(today).inDays;
      if (difference <= 7) {
        return 'Due in $difference days';
      }
      return 'Due ${date.day}/${date.month}';
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${widget.task.title}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete?.call();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showProgressDialog() {
    double tempProgress = widget.task.progress;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Update Progress'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current: ${widget.task.progressText}'),
              const SizedBox(height: 16),
              Text(
                'New: ${(tempProgress * 100).round()}%',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: tempProgress,
                onChanged: (value) => setState(() => tempProgress = value),
                activeColor: _getProgressColor(),
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
                await taskProvider.updateTaskProgress(
                  taskId: widget.task.id,
                  progress: tempProgress,
                );
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}