import 'package:flutter/material.dart';
import 'package:planmate/Services/notification.dart';
import 'package:planmate/provider/notificationprovider.dart';
import 'package:planmate/notification/widgets/date_header.dart';
import 'package:planmate/notification/widgets/notification_card.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('การแจ้งเตือน'),
        elevation: 0,
        actions: [
          // Mark all as read
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              return provider.hasUnread
                  ? IconButton(
                      icon: const Icon(Icons.done_all),
                      tooltip: 'อ่านทั้งหมด',
                      onPressed: () async {
                        await provider.markAllAsRead();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('อ่านทั้งหมดแล้ว'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    )
                  : const SizedBox.shrink();
            },
          ),

          // More options
          PopupMenuButton<String>(
            onSelected: (value) async {
              final provider = context.read<NotificationProvider>();
              if (value == 'clear_all') {
                final confirm = await _showConfirmDialog(
                  context,
                  'ลบการแจ้งเตือนทั้งหมด',
                  'คุณแน่ใจหรือไม่ที่จะลบการแจ้งเตือนทั้งหมด?',
                );
                if (confirm == true) {
                  await provider.clearAllNotifications();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ลบการแจ้งเตือนทั้งหมดแล้ว'),
                      ),
                    );
                  }
                }
              } else if (value == 'test') {
                await provider.sendTestNotification();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ส่งการแจ้งเตือนทดสอบแล้ว'),
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'test',
                child: Row(
                  children: [
                    Icon(Icons.send, size: 20),
                    SizedBox(width: 8),
                    Text('ส่งการแจ้งเตือนทดสอบ'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'ลบทั้งหมด',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          // Loading state
          if (!provider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'เกิดข้อผิดพลาด',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.refreshNotifications,
                    child: const Text('ลองอีกครั้ง'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ไม่มีการแจ้งเตือน',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'การแจ้งเตือนของคุณจะแสดงที่นี่',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          // Main content - Grouped by date
          return RefreshIndicator(
            onRefresh: () async {
              provider.refreshNotifications();
            },
            child: ListView.builder(
              itemCount: _getTotalItemCount(provider),
              itemBuilder: (context, index) {
                return _buildItem(context, provider, index);
              },
            ),
          );
        },
      ),
    );
  }

  // Calculate total item count (headers + notifications)
  int _getTotalItemCount(NotificationProvider provider) {
    final dateHeaders = provider.dateHeaders;
    int count = 0;
    for (final dateKey in dateHeaders) {
      count++; // Header
      count += provider.notificationsByDate[dateKey]?.length ?? 0;
    }
    return count;
  }

  // Build each item (header or notification card)
  Widget _buildItem(
    BuildContext context,
    NotificationProvider provider,
    int index,
  ) {
    final dateHeaders = provider.dateHeaders;
    int currentIndex = 0;

    for (final dateKey in dateHeaders) {
      // Check if this is a header
      if (currentIndex == index) {
        return DateHeader(
          dateText: provider.formatDateHeader(dateKey),
        );
      }
      currentIndex++;

      // Check if this is a notification in this date group
      final notifications = provider.notificationsByDate[dateKey] ?? [];
      final relativeIndex = index - currentIndex;

      if (relativeIndex >= 0 && relativeIndex < notifications.length) {
        final notification = notifications[relativeIndex];
        return NotificationCard(
          notification: notification,
          timeText: provider.formatTime(notification.receivedAt),
          onTap: () async {
            if (!notification.read) {
              await provider.markAsRead(notification.id);
            }
            _handleNotificationTap(context, notification);
          },
          onDismissed: () {
            // Handle dismissal if needed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('ลบการแจ้งเตือน: ${notification.title}'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      }

      currentIndex += notifications.length;
    }

    return const SizedBox.shrink();
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationLog notification,
  ) {
    final type = notification.notificationType;

    switch (type) {
      case 'achievement':
        _showAchievementDialog(context, notification);
        break;
      case 'weekly_summary':
        debugPrint('Navigate to statistics');
        break;
      case 'daily_reminder':
      case 'inactive_reminder':
        debugPrint('Navigate to tasks');
        break;
      default:
        break;
    }
  }

  void _showAchievementDialog(
    BuildContext context,
    NotificationLog notification,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(notification.icon, color: Colors.amber, size: 24), // ✅ ถูกต้อง
            const SizedBox(width: 8),
            const Text('ความสำเร็จ'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(notification.body),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context,
    String title,
    String content,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );
  }
}