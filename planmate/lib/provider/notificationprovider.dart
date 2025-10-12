import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:planmate/Services/notification.dart';
import 'package:intl/intl.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  // State variables
  List<NotificationLog> _notifications = [];
  int _unreadCount = 0;
  bool _isInitialized = false;
  String? _error;

  StreamSubscription<List<NotificationLog>>? _notificationsSubscription;
  StreamSubscription<int>? _unreadCountSubscription;

  // Getters
  List<NotificationLog> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get hasUnread => _unreadCount > 0;

  // Filtered notifications
  List<NotificationLog> get unreadNotifications =>
      _notifications.where((n) => !n.read).toList();

  List<NotificationLog> get readNotifications =>
      _notifications.where((n) => n.read).toList();

  // 🔥 NEW: Group notifications by date
  Map<String, List<NotificationLog>> get notificationsByDate {
    final grouped = <String, List<NotificationLog>>{};
    
    for (final notification in _notifications) {
      final dateKey = _getDateKey(notification.receivedAt);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(notification);
    }
    
    // Sort notifications within each group by time (newest first)
    grouped.forEach((key, list) {
      list.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    });
    
    return grouped;
  }

  // 🔥 NEW: Get sorted date headers
  List<String> get dateHeaders {
    final headers = notificationsByDate.keys.toList();
    headers.sort((a, b) => _parseDateKey(b).compareTo(_parseDateKey(a)));
    return headers;
  }

  // 🔥 NEW: Get date key for grouping (format: "YYYY-MM-DD")
  String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // 🔥 NEW: Parse date key back to DateTime
  DateTime _parseDateKey(String dateKey) {
    return DateTime.parse(dateKey);
  }

  // 🔥 NEW: Format date header for display (e.g., "01 ต.ค. 2025")
  String formatDateHeader(String dateKey) {
    final date = _parseDateKey(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'วันนี้';
    } else if (dateOnly == yesterday) {
      return 'เมื่อวาน';
    } else {
      // Format as "DD MMM YYYY" in Thai
      return DateFormat('dd MMM yyyy', 'th').format(date);
    }
  }

  // 🔥 NEW: Format time for notification card (e.g., "17:01")
  String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  // Group notifications by type
  Map<String, List<NotificationLog>> get groupedByType {
    final map = <String, List<NotificationLog>>{};
    for (final notification in _notifications) {
      final type = notification.notificationType;
      map[type] = [...(map[type] ?? []), notification];
    }
    return map;
  }

  // Constructor
  NotificationProvider() {
    _initialize();
  }

  /// Initialize notification provider
  Future<void> _initialize() async {
    try {
      debugPrint('🔄 Initializing NotificationProvider...');

      // Initialize notification service
      await _notificationService.initialize();

      // Start listening to notifications
      _startListeningToNotifications();

      // Start listening to unread count
      _startListeningToUnreadCount();

      _isInitialized = true;
      debugPrint('✅ NotificationProvider initialized successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed to initialize NotificationProvider: $e');
      _setError('Failed to initialize notifications: $e');
    }
  }

  /// Start listening to notifications
  void _startListeningToNotifications() {
    _notificationsSubscription?.cancel();

    _notificationsSubscription = _notificationService
        .getNotificationHistory()
        .listen(
          (notifications) {
            _notifications = notifications;
            _error = null;
            notifyListeners();
            debugPrint(
              '📦 Received ${notifications.length} notifications',
            );
          },
          onError: (error) {
            debugPrint('❌ Notifications stream error: $error');
            _setError('Failed to load notifications: $error');
          },
        );
  }

  /// Start listening to unread count
  void _startListeningToUnreadCount() {
    _unreadCountSubscription?.cancel();

    _unreadCountSubscription = _notificationService
        .getUnreadCount()
        .listen(
          (count) {
            _unreadCount = count;
            notifyListeners();
            debugPrint('📊 Unread count: $count');
          },
          onError: (error) {
            debugPrint('❌ Unread count stream error: $error');
          },
        );
  }

  /// Set error
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      debugPrint('✅ Marked notification as read: $notificationId');
    } catch (e) {
      debugPrint('❌ Failed to mark as read: $e');
      _setError('Failed to mark notification as read');
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    try {
      for (final notification in unreadNotifications) {
        await _notificationService.markAsRead(notification.id);
      }
      debugPrint('✅ Marked all notifications as read');
    } catch (e) {
      debugPrint('❌ Failed to mark all as read: $e');
      _setError('Failed to mark all as read');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await _notificationService.clearAllNotifications();
      debugPrint('✅ All notifications cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear notifications: $e');
      _setError('Failed to clear notifications');
    }
  }

  /// Delete specific notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      debugPrint('🔄 Deleting notification: $notificationId');
    } catch (e) {
      debugPrint('❌ Failed to delete notification: $e');
      _setError('Failed to delete notification');
    }
  }

  /// Send test notification
  Future<void> sendTestNotification() async {
    try {
      await _notificationService.sendTestNotification();
      debugPrint('✅ Test notification sent');
    } catch (e) {
      debugPrint('❌ Failed to send test notification: $e');
      _setError('Failed to send test notification');
    }
  }

  /// Get notifications by type
  List<NotificationLog> getNotificationsByType(String type) {
    return _notifications
        .where((n) => n.notificationType == type)
        .toList();
  }

  /// Get today's notifications
  List<NotificationLog> get todayNotifications {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _notifications.where((n) {
      return n.receivedAt.isAfter(today);
    }).toList();
  }

  /// Get this week's notifications
  List<NotificationLog> get weekNotifications {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return _notifications.where((n) {
      return n.receivedAt.isAfter(weekAgo);
    }).toList();
  }

  /// Get notification statistics
  Map<String, int> get notificationStats {
    final achievements = getNotificationsByType('achievement').length;
    final reminders =
        getNotificationsByType('daily_reminder').length +
        getNotificationsByType('inactive_reminder').length;
    final summaries = getNotificationsByType('weekly_summary').length;

    return {
      'total': _notifications.length,
      'unread': _unreadCount,
      'achievements': achievements,
      'reminders': reminders,
      'summaries': summaries,
    };
  }

  /// Refresh notifications
  void refreshNotifications() {
    debugPrint('🔄 Refreshing notifications');
    _startListeningToNotifications();
    _startListeningToUnreadCount();
  }

  @override
  void dispose() {
    debugPrint('🗑️ Disposing NotificationProvider');
    _notificationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    _notificationService.dispose();
    super.dispose();
  }
}