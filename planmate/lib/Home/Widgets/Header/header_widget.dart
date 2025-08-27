import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:planmate/provider/auth_provider.dart';
import 'package:provider/provider.dart';


class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    // ฟังเฉพาะ field ที่ใช้ เพื่อลด rebuild
    final photoURL    = context.select<AuthProvider, String?>((p) => p.photoURL);
    final displayName = context.select<AuthProvider, String>((p) => p.displayName);

    final name = (displayName.isNotEmpty) ? displayName : 'Guest';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: (photoURL != null && photoURL.isNotEmpty)
                  ? NetworkImage(photoURL)
                  : const AssetImage('assets/avatar/NogoogleImage.png') as ImageProvider,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Welcome,', style: TextStyle(color: Color(0xFF172c66))),
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
            GestureDetector(
              onTap: () {
                // TODO: handle notification tap
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(59, 215, 179, 179),
                ),
                child: const Icon(
                  FontAwesomeIcons.solidBell,
                  color: Color(0xFF001858),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
