import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyTaskState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onCreateTask;
  final bool showCreateButton;

  const EmptyTaskState({
    super.key,
    this.title = 'No tasks yet',
    this.subtitle = 'Add your first task to get started',
    this.onCreateTask,
    this.showCreateButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie animation
          Lottie.asset(
            'assets/lottie/hero.json',
            width: 200,
            height: 200,
            repeat: true,
            animate: true,
          ),
          
          const SizedBox(height: 24),
          
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF001858),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF172c66),
            ),
            textAlign: TextAlign.center,
          ),
          
          // Create button (optional)
          if (showCreateButton && onCreateTask != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreateTask,
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}