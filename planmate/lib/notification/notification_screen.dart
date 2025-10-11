import 'package:flutter/material.dart';
import 'package:planmate/Services/notification.dart';
import 'package:planmate/provider/notificationprovider.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('การแจ้งเตือน'),
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
          // Clear all
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
            itemBuilder:
                (context) => [
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
                        Icon(
                          Icons.delete_sweep,
                          size: 20,
                          color: Colors.red,
                        ),
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
          if (!provider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

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
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
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
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'การแจ้งเตือนของคุณจะแสดงที่นี่',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              provider.refreshNotifications();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Statistics card
                _buildStatsCard(context, provider),
                const SizedBox(height: 16),

                // Unread notifications
                if (provider.unreadNotifications.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    'ยังไม่ได้อ่าน',
                    provider.unreadCount,
                  ),
                  const SizedBox(height: 8),
                  ...provider.unreadNotifications.map(
                    (n) => _buildNotificationCard(context, n, provider),
                  ),
                  const SizedBox(height: 16),
                ],

                // Read notifications
                if (provider.readNotifications.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    'อ่านแล้ว',
                    provider.readNotifications.length,
                  ),
                  const SizedBox(height: 8),
                  ...provider.readNotifications.map(
                    (n) => _buildNotificationCard(context, n, provider),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    NotificationProvider provider,
  ) {
    final stats = provider.notificationStats;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สถิติการแจ้งเตือน',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  '📬',
                  'ทั้งหมด',
                  stats['total']!,
                  Colors.blue,
                ),
                _buildStatItem(
                  context,
                  '🔔',
                  'ยังไม่อ่าน',
                  stats['unread']!,
                  Colors.orange,
                ),
                _buildStatItem(
                  context,
                  '🏆',
                  'ความสำเร็จ',
                  stats['achievements']!,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String emoji,
    String label,
    int value,
    Color color,
  ) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    int count,
  ) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationLog notification,
    NotificationProvider provider,
  ) {
    final isUnread = !notification.read;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: isUnread ? 2 : 0,
        color: isUnread ? Colors.blue.withOpacity(0.05) : null,
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () async {
            if (isUnread) {
              await provider.markAsRead(notification.id);
            }
            // Navigate to relevant screen
            _handleNotificationTap(context, notification);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getColorForType(
                      notification.notificationType,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      notification.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: Theme.of(
                                context,
                              ).textTheme.titleSmall?.copyWith(
                                fontWeight:
                                    isUnread
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.timeAgo,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'achievement':
        return Colors.green;
      case 'weekly_summary':
        return Colors.blue;
      case 'daily_reminder':
        return Colors.orange;
      case 'inactive_reminder':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationLog notification,
  ) {
    final type = notification.notificationType;

    switch (type) {
      case 'achievement':
        // Show achievement details
        _showAchievementDialog(context, notification);
        break;
      case 'weekly_summary':
        // Navigate to statistics
        debugPrint('Navigate to statistics');
        break;
      case 'daily_reminder':
      case 'inactive_reminder':
        // Navigate to tasks
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
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Text(notification.emoji),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
      builder:
          (context) => AlertDialog(
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
