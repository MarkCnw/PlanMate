import 'package:flutter/material.dart';

class ProjectSectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback? onActionTap;

  const ProjectSectionHeader({
    super.key,
    this.title = 'Our Project',
    this.actionText = 'See Detail',
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF001858)
          ),
        ),
        GestureDetector(
          onTap: onActionTap,
          child: Text(
            actionText,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF172c66),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
