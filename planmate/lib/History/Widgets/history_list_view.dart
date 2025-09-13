

import 'package:flutter/material.dart';
import 'package:planmate/History/Provider/history_provider.dart';
import 'package:planmate/History/Widgets/history_item_widget.dart';
import 'package:provider/provider.dart';

class HistoryListView extends StatelessWidget {
  const HistoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, child) {
        final activities = historyProvider.filteredActivities;
        
        return RefreshIndicator(
          onRefresh: () async {
            await historyProvider.refreshActivities();
          },
          // color: const Color(0xFF8B5CF6),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: HistoryItemWidget(
                  activity: activity,
                ),
              );
            },
          ),
        );
      },
    );
  }
}