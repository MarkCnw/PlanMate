import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ NotificationService already initialized');
      return;
    }

    try {
      debugPrint('🔄 Initializing NotificationService...');

      // Request permission
      await _requestPermission();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get and save FCM token
      await _saveFCMToken();

      // Setup message handlers
      _setupMessageHandlers();

      // Listen to token refresh
      _messaging.onTokenRefresh.listen(_updateFCMToken);

      _isInitialized = true;
      debugPrint('✅ NotificationService initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize NotificationService: $e');
      rethrow;
    }
  }

  /// Request notification permission
  Future<void> _requestPermission() async {
    debugPrint('🔄 Requesting notification permission...');

    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('📍 Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ Notification permission granted');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('⚠️ Notification permission provisional');
    } else {
      debugPrint('❌ Notification permission denied');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    debugPrint('🔄 Initializing local notifications...');

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    debugPrint('✅ Local notifications initialized');
  }

  /// Save FCM token to Firestore
  Future<void> _saveFCMToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ No user logged in, skipping FCM token save');
        return;
      }

      final token = await _messaging.getToken();
      if (token == null) {
        debugPrint('⚠️ No FCM token available');
        return;
      }

      debugPrint('📍 FCM Token: ${token.substring(0, 20)}...');

      // Save token to Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ FCM token saved to Firestore');
    } catch (e) {
      debugPrint('❌ Failed to save FCM token: $e');
    }
  }

  /// Update FCM token when it refreshes
  Future<void> _updateFCMToken(String token) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      debugPrint('🔄 FCM token refreshed');

      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ FCM token updated');
    } catch (e) {
      debugPrint('❌ Failed to update FCM token: $e');
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Handle terminated state messages
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleBackgroundMessage(message);
      }
    });

    debugPrint('✅ Message handlers setup complete');
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📨 Foreground message received');
    debugPrint('📍 Title: ${message.notification?.title}');
    debugPrint('📍 Body: ${message.notification?.body}');
    debugPrint('📍 Data: ${message.data}');

    // Show local notification
    await _showLocalNotification(message);

    // Log notification
    await _logNotification(message);
  }

  /// Handle background/terminated messages
  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('📨 Background message received');
    debugPrint('📍 Title: ${message.notification?.title}');
    debugPrint('📍 Body: ${message.notification?.body}');
    debugPrint('📍 Data: ${message.data}');

    // Navigate based on notification type
    _handleNotificationNavigation(message.data);
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'planmate_channel',
      'PlanMate Notifications',
      channelDescription: 'Notifications for PlanMate app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📱 Notification tapped');
    debugPrint('📍 Payload: ${response.payload}');

    // Parse payload and navigate
    // You can implement navigation logic here
  }

  /// Handle notification navigation
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    switch (type) {
      case 'inactive_reminder':
      case 'daily_reminder':
        // Navigate to home/tasks
        debugPrint('🔄 Navigate to tasks');
        break;
      case 'weekly_summary':
        // Navigate to statistics
        debugPrint('🔄 Navigate to statistics');
        break;
      case 'achievement':
        // Show achievement dialog
        debugPrint('🔄 Show achievement');
        break;
      default:
        debugPrint('⚠️ Unknown notification type: $type');
    }
  }

  /// Log notification to Firestore
  Future<void> _logNotification(RemoteMessage message) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('notification_logs').add({
        'userId': user.uid,
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': message.data,
        'receivedAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      debugPrint('❌ Failed to log notification: $e');
    }
  }

  /// Get notification history
  Stream<List<NotificationLog>> getNotificationHistory() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('notification_logs')
        .where('userId', isEqualTo: user.uid)
        .orderBy('receivedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return NotificationLog(
          id: doc.id,
          title: data['title'] ?? '',
          body: data['body'] ?? '',
          data: Map<String, dynamic>.from(data['data'] ?? {}),
          receivedAt: (data['receivedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          read: data['read'] ?? false,
        );
      }).toList();
    });
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notification_logs').doc(notificationId).update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('❌ Failed to mark notification as read: $e');
    }
  }

  /// Get unread notification count
  Stream<int> getUnreadCount() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('notification_logs')
        .where('userId', isEqualTo: user.uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('notification_logs')
          .where('userId', isEqualTo: user.uid)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      debugPrint('✅ All notifications cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear notifications: $e');
    }
  }

  /// Test notification (for debugging)
  Future<void> sendTestNotification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ No user logged in');
        return;
      }

      // Call Cloud Function to send test notification
      // You'll need to implement this callable function
      debugPrint('🔄 Sending test notification...');

      await _showLocalNotification(RemoteMessage(
        notification: const RemoteNotification(
          title: '🔔 ทดสอบการแจ้งเตือน',
          body: 'นี่คือการแจ้งเตือนทดสอบ',
        ),
        data: {'type': 'test'},
      ));

      debugPrint('✅ Test notification sent');
    } catch (e) {
      debugPrint('❌ Failed to send test notification: $e');
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Failed to subscribe to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Failed to unsubscribe from topic: $e');
    }
  }

  /// Cleanup
  void dispose() {
    debugPrint('🗑️ Disposing NotificationService');
  }
}

// ===== MODELS =====

class NotificationLog {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime receivedAt;
  final bool read;

  NotificationLog({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.receivedAt,
    required this.read,
  });

  String get notificationType => data['type'] ?? 'unknown';

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(receivedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} วันที่แล้ว';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else {
      return 'เมื่อสักครู่';
    }
  }

  String get emoji {
    switch (notificationType) {
      case 'achievement':
        return '🏆';
      case 'weekly_summary':
        return '📊';
      case 'daily_reminder':
        return '📝';
      case 'inactive_reminder':
        return '💙';
      default:
        return '🔔';
    }
  }
}

// ===== BACKGROUND MESSAGE HANDLER =====
// This must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📨 Background message handler');
  debugPrint('📍 Title: ${message.notification?.title}');
  debugPrint('📍 Body: ${message.notification?.body}');
  debugPrint('📍 Data: ${message.data}');
}