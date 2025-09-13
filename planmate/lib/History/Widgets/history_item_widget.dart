import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:planmate/History/Models/activity_history_model.dart';
import 'package:planmate/provider/project_provider.dart';

class HistoryItemWidget extends StatelessWidget {
  final ActivityHistoryModel activity;

  const HistoryItemWidget({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
     
      child: Row(
        children: [
          // Activity Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getTypeColor(activity.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _getTypeIcon(activity.type),
              color: _getTypeColor(activity.type),
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  activity.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF001858),
                  ),
                ),

                const SizedBox(height: 4),

                // Project info
                Consumer<ProjectProvider>(
                  builder: (context, projectProvider, child) {
                    final project = projectProvider.getProjectById(
                      activity.projectId,
                    );
                    return Text(
                      // ✅ เปลี่ยนจาก project?.name เป็น project?.title
                      'โปรเจกต์: ${project?.title ?? 'ไม่พบโปรเจกต์'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),

                // Task info (if exists)
              
                 
              ],
            ),
          ),

          // Timestamp
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                activity.formattedTime,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),

              
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.create:
        return Icons.add_circle_outline;
      case ActivityType.update:
        return Icons.edit_outlined;
      case ActivityType.complete:
        return Icons.check_circle_outline;
      case ActivityType.delete:
        return Icons.delete_outline;
    }
  }

  Color _getTypeColor(ActivityType type) {
    switch (type) {
      case ActivityType.create:
        return Colors.green;
      case ActivityType.update:
        return Colors.blue;
      case ActivityType.complete:
        return Colors.orange;
      case ActivityType.delete:
        return Colors.red;
    }
  }
}
