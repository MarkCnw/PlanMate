import 'package:flutter/material.dart';
import 'package:planmate/Services/notification.dart'; // Make sure this import is correct

class NotificationCard extends StatelessWidget {
  final NotificationLog notification;
  final String timeText;
  final VoidCallback onTap;
  final VoidCallback? onDismissed;

  const NotificationCard({
    Key? key,
    required this.notification,
    required this.timeText,
    required this.onTap,
    this.onDismissed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUnread = !notification.read;
    final typeColor = _getColorForType(notification.notificationType);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        // ใช้เส้นขอบบางๆ ด้านล่างเพื่อแบ่งแต่ละรายการออกจากกันอย่างสวยงาม
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1.0),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ไอคอนที่ออกแบบใหม่
            _buildIcon(typeColor, isUnread),
            const SizedBox(width: 16.0),
            
            // ส่วนเนื้อหา (Title, Body) และเวลา
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ใช้ Expanded เพื่อให้ Title ไม่ล้นไปทับเวลา
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // เวลา
                      Text(
                        timeText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  // รายละเอียด
                  Text(
                    notification.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      height: 1.4, // เพิ่มความสูงระหว่างบรรทัดให้อ่านง่าย
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(Color color, bool isUnread) {
    // ใช้ Stack เพื่อวาง "จุด" unread indicator บนไอคอน
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            notification.icon,
            color: color, // ใช้สีของประเภทการแจ้งเตือน
            size: 26,
          ),
        ),
        if (isUnread)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.blueAccent, // สีของจุด unread ที่เด่นชัด
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  Color _getColorForType(String type) {
    // ปรับเฉดสีให้ดูสบายตาขึ้น
    switch (type) {
      case 'achievement':
        return Colors.green.shade500;
      case 'weekly_summary':
        return Colors.indigo.shade400;
      case 'daily_reminder':
        return Colors.orange.shade600;
      case 'inactive_reminder':
        return Colors.purple.shade400;
      default:
        return Colors.grey.shade600;
    }
  }
}