import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:planmate/History/Models/activity_history_model.dart';
import 'package:planmate/provider/project_provider.dart';
import 'package:intl/intl.dart';

class HistoryItemWidget extends StatelessWidget {
  final ActivityHistoryModel activity;
  final bool isLast;

  const HistoryItemWidget({
    super.key, 
    required this.activity,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column (left side)
          SizedBox(
            width: 60,
            child: Column(
              children: [
                // Icon circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getTypeColor(activity.type),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getTypeIcon(activity.type),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                
                // Connecting line (แสดงเส้นต่อยกเว้นรายการสุดท้าย)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 8),
                      color: Colors.grey[300],
                    ),
                  ),
              ],
            ),
          ),
          
          // Content area (right side)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and time (แบบรูปภาพที่ 2)
                  Text(
                    _formatDateTime(activity.timestamp),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Activity title/description
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
                       'Project: ${project?.title ?? 'ไม่พบโปรเจกต์'}',
                        
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Format datetime like "10th January, 10:40"
  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day;
    final dayWithSuffix = _getDayWithSuffix(day);
    final month = DateFormat('MMMM', 'en_US').format(dateTime);
    final time = DateFormat('HH:mm').format(dateTime);
    
    return '$dayWithSuffix $month, $time';
  }

  // Get day with ordinal suffix (1st, 2nd, 3rd, 4th, etc.)
  String _getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  IconData _getTypeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.create:
        return FontAwesomeIcons.plus  ;
      case ActivityType.update:
        return FontAwesomeIcons.pen;
      case ActivityType.complete:
        return FontAwesomeIcons.check;
      case ActivityType.delete:
        return FontAwesomeIcons.trash;
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