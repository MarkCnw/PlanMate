import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:planmate/History/Provider/history_provider.dart';
import 'package:planmate/provider/auth_provider.dart';
import 'package:planmate/History/Widgets/history_filter_bar.dart';
import 'package:planmate/History/Widgets/history_list_view.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadActivities());
  }

  void _loadActivities() {
    final auth = context.read<AuthProvider>();
    final history = context.read<HistoryProvider>();
    if (auth.currentUser != null) {
      history.fetchActivities(userId: auth.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // ถ้า theme มี scaffoldBackgroundColor = Colors.white อยู่แล้ว จะลบบรรทัดนี้ก็ได้
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const HistoryFilterBar(),
            Expanded(
              child: Consumer<HistoryProvider>(
                builder: (context, historyProvider, _) {
                  if (historyProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                    );
                  }
      
                  if (historyProvider.error != null) {
                    return _ErrorState(
                      message: historyProvider.error!,
                      onRetry: _loadActivities,
                    );
                  }
      
                  final activities = historyProvider.filteredActivities;
      
                  if (activities.isEmpty) {
                    final filtered = historyProvider.selectedFilter != null ||
                        historyProvider.selectedProjectId != null;
                    return _EmptyState(
                      message: filtered
                          ? 'ไม่พบกิจกรรมที่ตรงกับตัวกรอง'
                          : 'ยังไม่มีประวัติกิจกรรม',
                    );
                  }
      
                  return const HistoryListView();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
            Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
            ),
            child: const Text('ลองใหม่'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}