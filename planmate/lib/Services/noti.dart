
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// // ฟังก์ชันนี้ต้องอยู่นอกคลาส (Top-level function) เพื่อให้ทำงานใน Background ได้
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(
//   RemoteMessage message,
// ) async {
//   // หากคุณต้องการทำอะไรบางอย่างกับข้อความที่ได้รับใน Background
//   // เช่น บันทึกข้อมูลลงฐานข้อมูล ก็ทำได้ที่นี่
//   print("📳 Handling a background message: ${message.messageId}");
// }

// class NotificationService {
//   final FirebaseMessaging _fcm = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _localNotifications =
//       FlutterLocalNotificationsPlugin();

//   /// 1. จัดการเมื่อผู้ใช้กด Notification ตอนแอปปิดสนิท (Terminated)
//   Future<void> _handleTerminatedStateMessage() async {
//     RemoteMessage? initialMessage = await _fcm.getInitialMessage();

//     if (initialMessage != null) {
//       print(
//         "📱 App opened from terminated state by message: ${initialMessage.data}",
//       );
//       // TODO: ใส่ Logic การนำทาง (Navigation) ไปยังหน้าที่ต้องการที่นี่
//       // ตัวอย่าง: navigatorKey.currentState?.pushNamed('/details', arguments: initialMessage.data);
//     }
//   }

//   /// 2. จัดการเมื่อแอปเปิดอยู่ (Foreground) และได้รับ Notification
//   void _handleForegroundMessage() {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Foreground message received: ${message.notification?.title}');

//       if (message.notification != null) {
//         // ใช้ flutter_local_notifications เพื่อแสดงการแจ้งเตือน
//         _showLocalNotification(message);
//       }
//     });
//   }

//   /// 3. จัดการเมื่อผู้ใช้กด Notification ตอนแอปอยู่เบื้องหลัง (Background)
//   void _handleBackgroundStateMessage() {
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print(
//         "📱 App opened from background state by message: ${message.data}",
//       );
//       // TODO: ใส่ Logic การนำทาง (Navigation) ไปยังหน้าที่ต้องการที่นี่
//     });
//   }

//   /// ฟังก์ชันสำหรับแสดง Local Notification (ใช้ตอนแอปอยู่ Foreground)
//   void _showLocalNotification(RemoteMessage message) {
//     final notification = message.notification;
//     if (notification == null) return;

//     final androidDetails = const AndroidNotificationDetails(
//       'high_importance_channel', // id ของ channel (ต้องตรงกับใน AndroidManifest)
//       'High Importance Notifications',
//       channelDescription:
//           'This channel is used for important notifications.',
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//     );

//     final notificationDetails = NotificationDetails(
//       android: androidDetails,
//       // iOS: ... (ตั้งค่าสำหรับ iOS ถ้าต้องการ)
//     );

//     _localNotifications.show(
//       notification.hashCode,
//       notification.title,
//       notification.body,
//       notificationDetails,
//       payload: message.data['route'], // ตัวอย่างการส่งข้อมูลเพื่อใช้ตอนกด
//     );
//   }

//   /// ฟังก์ชันหลักสำหรับตั้งค่าทั้งหมด
//   Future<void> init() async {
//     // 1. ขออนุญาต (Request Permission)
//     NotificationSettings settings = await _fcm.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('✅ User granted permission');

//       // 2. ตั้งค่า Local Notifications (สำหรับ Foreground)
//       await _localNotifications.initialize(
//         const InitializationSettings(
//           android: AndroidInitializationSettings(
//             '@mipmap/ic_launcher',
//           ), // ใช้ไอคอนแอปของคุณ
//           // iOS: ...
//         ),
//         // จัดการเมื่อผู้ใช้กด Local Notification
//         onDidReceiveNotificationResponse: (details) {
//           print(
//             "User tapped local notification with payload: ${details.payload}",
//           );
//           // TODO: ใส่ Logic การนำทาง (Navigation) ที่นี่
//         },
//       );

//       // 3. ดึง FCM Token
//       final token = await _fcm.getToken();
//       print("🔑 FCM Token: $token");
//       // TODO: ส่ง Token นี้ไปเก็บที่ Firestore ของ User ที่ล็อกอินอยู่

//       // 4. ตั้งค่า Listener สำหรับสถานะต่างๆ
//       _handleTerminatedStateMessage();
//       _handleForegroundMessage();
//       _handleBackgroundStateMessage();

//       // 5. ตั้งค่า Background Message Handler
//       FirebaseMessaging.onBackgroundMessage(
//         _firebaseMessagingBackgroundHandler,
//       );
//     } else {
//       print('❌ User declined or has not accepted permission');
//     }
//   }
// }
