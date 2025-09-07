// ... imports อื่นตามของเดิม
import 'package:flutter/material.dart';
import 'package:planmate/Models/task_model.dart';

class TaskItem extends StatefulWidget {
  final TaskModel task;
  final bool isLoading;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskItem({
    super.key,
    required this.task,
    this.isLoading = false,
    this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.isLoading ? 0.5 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.task.isDone
                ? Colors.green.withOpacity(0.25)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: widget.onToggle,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 14, top: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.task.isDone
                          ? Colors.green
                          : const Color(0xFF8B5CF6),
                      width: 2,
                    ),
                    color: widget.task.isDone
                        ? Colors.green
                        : Colors.white,
                  ),
                  child: widget.task.isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
              Expanded(child: _buildContent()),
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'edit') widget.onEdit?.call();
                  if (val == 'delete') widget.onDelete?.call();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              )
            ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.task.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  decoration: widget.task.isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: widget.task.isDone
                      ? Colors.grey.shade500
                      : Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(width: 6),
            _buildStatusBadge(),
          ],
        ),
        if (widget.task.hasDescription) ...[
          const SizedBox(height: 4),
            Text(
              widget.task.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: widget.task.isDone
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
                decoration: widget.task.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
        ],
        const SizedBox(height: 10),
        _buildMetadata(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    if (widget.task.isDone) {
      return _badge('Done', Colors.green);
    }
    switch (widget.task.status) {
      case TaskStatus.inProgress:
        return _badge('Active', Colors.blue);
      case TaskStatus.paused:
        return _badge('Paused', Colors.orange);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMetadata() {
    final chips = <Widget>[];

    if (widget.task.hasDueDate) {
      chips.add(_meta(
        icon: Icons.schedule,
        text: _formatDue(widget.task.dueDate!),
        color: _dueColor(),
      ));
    }

    if (widget.task.hasProgress) {
      chips.add(_meta(
        icon: Icons.trending_up,
        text: widget.task.progressText,
        color: _progressColor(),
      ));
    }

    // Priority chip
    chips.add(_meta(
      icon: Icons.flag,
      text: widget.task.priorityText,
      color: _priorityColor(widget.task.priority),
    ));

    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: chips,
    );
  }

  Widget _meta({required IconData icon, required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }

  String _formatDue(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dd = DateTime(d.year, d.month, d.day);
    if (dd == today) return 'Today';
    if (dd == today.add(const Duration(days: 1))) return 'Tomorrow';
    return '${d.day}/${d.month}';
  }

  Color _dueColor() {
    if (widget.task.isDone) return Colors.grey;
    if (!widget.task.hasDueDate) return Colors.grey;
    final now = DateTime.now();
    if (widget.task.dueDate!.isBefore(now) && !widget.task.isDone) {
      return Colors.red;
    }
    return Colors.indigo;
  }

  Color _progressColor() {
    final p = widget.task.progress;
    if (p >= 1.0) return Colors.green;
    if (p >= 0.75) return Colors.blue;
    if (p >= 0.4) return Colors.orange;
    return Colors.purple;
  }

  Color _priorityColor(int p) {
    switch (p) {
      case 1:
        return Colors.redAccent;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}