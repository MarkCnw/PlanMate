// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:planmate/Themes/apptypography.dart';

class HeaderSection extends StatelessWidget {
  final User? user;

  const HeaderSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : const AssetImage('assets/avatar/NogoogleImage.png')
                          as ImageProvider,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome,',
                    style: TextStyle(color: Color(0xFF172c66)),
                  ),
                  Text(
                    user?.displayName ?? 'Ronalldo',
                    style: AppTypography.heading2.copyWith(
                      color: Color(0xFF001858)
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                // handle tap
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
