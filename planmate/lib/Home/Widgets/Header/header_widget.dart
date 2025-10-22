import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:planmate/notification/notification_screen.dart';
import 'package:planmate/provider/auth_provider.dart';
import 'package:planmate/provider/notificationprovider.dart';
import 'package:provider/provider.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final photoURL = context.select<AuthProvider, String?>(
      (p) => p.photoURL,
    );
    final displayName = context.select<AuthProvider, String>(
      (p) => p.displayName,
    );
    final name = (displayName.isNotEmpty) ? displayName : 'Guest';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  (photoURL != null && photoURL.isNotEmpty)
                      ? NetworkImage(photoURL)
                      : const AssetImage('assets/avatar/NogoogleImage.png')
                          as ImageProvider,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hello,',
                    style: TextStyle(color: Color(0xFF172c66)),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF001858),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            
           

            // 🔥 Notification Button with Badge (แก้ไขแล้ว)
            const NotificationBellButton(),
          ],
        ),
      ],
    );
  }
}

// 🔥 Widget แยกสำหรับ Notification Bell (ถูกต้อง)
class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: () {
            // ✅ ไปหน้า NotificationScreen (ไม่ใช่ NotificationBellIcon!)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(59, 215, 179, 179),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Bell Icon
                const Icon(
                  FontAwesomeIcons.solidBell,
                  color: Color(0xFF001858),
                  size: 20,
                ),

                // 🔥 Badge แสดงจำนวน unread
                if (provider.hasUnread)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        provider.unreadCount > 99
                            ? '99+'
                            : provider.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}


