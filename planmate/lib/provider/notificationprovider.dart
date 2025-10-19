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

  // ✅ เพิ่ม flag เพื่อป้องกัน double initialization
  bool _isInitializing = false;

  // Getters
  List<NotificationLog> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get hasUnread => _unreadCount > 0;

  List<NotificationLog> get unreadNotifications =>
      _notifications.where((n) => !n.read).toList();

  List<NotificationLog> get readNotifications =>
      _notifications.where((n) => n.read).toList();

  // Group notifications by date
  Map<String, List<NotificationLog>> get notificationsByDate {
    final grouped = <String, List<NotificationLog>>{};
    
    for (final notification in _notifications) {
      final dateKey = _getDateKey(notification.receivedAt);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(notification);
    }
    
    grouped.forEach((key, list) {
      list.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    });
    
    return grouped;
  }

  List<String> get dateHeaders {
    final headers = notificationsByDate.keys.toList();
    headers.sort((a, b) => _parseDateKey(b).compareTo(_parseDateKey(a)));
    return headers;
  }

  String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  DateTime _parseDateKey(String dateKey) {
    return DateTime.parse(dateKey);
  }

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
      return DateFormat('dd MMM yyyy', 'th').format(date);
    }
  }

  String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  Map<String, List<NotificationLog>> get groupedByType {
    final map = <String, List<NotificationLog>>{};
    for (final notification in _notifications) {
      final type = notification.notificationType;
      map[type] = [...(map[type] ?? []), notification];
    }
    return map;
  }

  // Constructor - ไม่เรียก _initialize() ที่นี่
  NotificationProvider();

  /// ✅ Initialize with guard to prevent multiple calls
  Future<void> _initialize() async {
    // ป้องกันการ initialize ซ้ำ
    if (_isInitialized || _isInitializing) {
      debugPrint('⚠️ NotificationProvider already initialized or initializing');
      return;
    }

    _isInitializing = true;

    try {
      debugPrint('🔄 Initializing NotificationProvider...');

      // Initialize notification service
      await _notificationService.initialize();

      // Start listening to notifications
      _startListeningToNotifications();

      // Start listening to unread count
      _startListeningToUnreadCount();

      _isInitialized = true;
      _isInitializing = false;
      
      debugPrint('✅ NotificationProvider initialized successfully');
      notifyListeners();
    } catch (e) {
      _isInitializing = false;
      debugPrint('❌ Failed to initialize NotificationProvider: $e');
      _setError('Failed to initialize notifications: $e');
    }
  }

  /// ✅ เพิ่ม method สำหรับ manual initialization
  Future<void> initialize() async {
    if (!_isInitialized && !_isInitializing) {
      await _initialize();
    }
  }

  /// ✅ Start listening with proper cleanup
  void _startListeningToNotifications() {
    // ยกเลิก subscription เก่าก่อน
    _notificationsSubscription?.cancel();
    _notificationsSubscription = null;

    debugPrint('🔄 Starting to listen to notifications...');

    _notificationsSubscription = _notificationService
        .getNotificationHistory()
        .listen(
          (notifications) {
            // ✅ เช็คว่า notification เปลี่ยนแปลงจริงหรือไม่
            if (_notifications.length != notifications.length ||
                !_areNotificationsSame(_notifications, notifications)) {
              _notifications = notifications;
              _error = null;
              notifyListeners();
              debugPrint('📦 Received ${notifications.length} notifications');
            } else {
              debugPrint('⏭️ Skip duplicate notification update');
            }
          },
          onError: (error) {
            debugPrint('❌ Notifications stream error: $error');
            _setError('Failed to load notifications: $error');
          },
        );
  }

  /// ✅ เช็คว่า list ของ notification เหมือนกันหรือไม่
  bool _areNotificationsSame(
    List<NotificationLog> list1,
    List<NotificationLog> list2,
  ) {
    if (list1.length != list2.length) return false;
    
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id || list1[i].read != list2[i].read) {
        return false;
      }
    }
    return true;
  }

  /// ✅ Start listening to unread count with proper cleanup
  void _startListeningToUnreadCount() {
    // ยกเลิก subscription เก่าก่อน
    _unreadCountSubscription?.cancel();
    _unreadCountSubscription = null;

    debugPrint('🔄 Starting to listen to unread count...');

    _unreadCountSubscription = _notificationService
        .getUnreadCount()
        .listen(
          (count) {
            // ✅ อัพเดตเฉพาะเมื่อค่าเปลี่ยน
            if (_unreadCount != count) {
              _unreadCount = count;
              notifyListeners();
              debugPrint('📊 Unread count: $count');
            }
          },
          onError: (error) {
            debugPrint('❌ Unread count stream error: $error');
          },
        );
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// ✅ Mark as read with debounce to prevent duplicate calls
  final Map<String, bool> _markingAsRead = {};

  Future<void> markAsRead(String notificationId) async {
    // ป้องกันการเรียกซ้ำ
    if (_markingAsRead[notificationId] == true) {
      debugPrint('⏭️ Already marking notification as read: $notificationId');
      return;
    }

    try {
      _markingAsRead[notificationId] = true;
      await _notificationService.markAsRead(notificationId);
      debugPrint('✅ Marked notification as read: $notificationId');
    } catch (e) {
      debugPrint('❌ Failed to mark as read: $e');
      _setError('Failed to mark notification as read');
    } finally {
      // ลบ flag หลังจาก 1 วินาที
      Future.delayed(const Duration(seconds: 1), () {
        _markingAsRead.remove(notificationId);
      });
    }
  }

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

  Future<void> clearAllNotifications() async {
    try {
      await _notificationService.clearAllNotifications();
      debugPrint('✅ All notifications cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear notifications: $e');
      _setError('Failed to clear notifications');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      debugPrint('🔄 Deleting notification: $notificationId');
    } catch (e) {
      debugPrint('❌ Failed to delete notification: $e');
      _setError('Failed to delete notification');
    }
  }

  Future<void> sendTestNotification() async {
    try {
      await _notificationService.sendTestNotification();
      debugPrint('✅ Test notification sent');
    } catch (e) {
      debugPrint('❌ Failed to send test notification: $e');
      _setError('Failed to send test notification');
    }
  }

  List<NotificationLog> getNotificationsByType(String type) {
    return _notifications
        .where((n) => n.notificationType == type)
        .toList();
  }

  List<NotificationLog> get todayNotifications {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _notifications.where((n) {
      return n.receivedAt.isAfter(today);
    }).toList();
  }

  List<NotificationLog> get weekNotifications {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return _notifications.where((n) {
      return n.receivedAt.isAfter(weekAgo);
    }).toList();
  }

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

  /// ✅ Refresh with guard to prevent multiple calls
  bool _isRefreshing = false;

  void refreshNotifications() {
    if (_isRefreshing) {
      debugPrint('⏭️ Already refreshing notifications');
      return;
    }

    _isRefreshing = true;
    debugPrint('🔄 Refreshing notifications');
    
    _startListeningToNotifications();
    _startListeningToUnreadCount();
    
    // Reset flag after delay
    Future.delayed(const Duration(seconds: 2), () {
      _isRefreshing = false;
    });
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