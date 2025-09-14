import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:planmate/History/Provider/history_provider.dart';
import 'package:planmate/provider/project_provider.dart';
import 'package:planmate/History/Models/activity_history_model.dart';

class HistoryFilterBar extends StatelessWidget {
  const HistoryFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Filter
          const Text(
            'Project',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF001858),
            ),
          ),
          const SizedBox(height: 8),
          Consumer2<HistoryProvider, ProjectProvider>(
            builder: (context, historyProvider, projectProvider, child) {
              final projects = projectProvider.projects;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: historyProvider.selectedProjectId,
                    hint: const Text('เลือกโปรเจกต์'),
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    onChanged: (value) {
                      historyProvider.setProjectFilter(value);
                    },
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All'),
                      ),
                      ...projects.map((project) {
                        return DropdownMenuItem<String>(
                          value: project.id,
                          child: Text(project.title),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Activity Type Filters - Underline Tab Style
          const SizedBox(height: 8),
          Consumer<HistoryProvider>(
            builder: (context, historyProvider, child) {
              return Container(
                height: 50,
                child: Row(
                  children: [
                    // All tab
                    _buildUnderlineTab(
                      text: 'All',
                      isSelected: historyProvider.selectedFilter == null,
                      onTap: () => historyProvider.setFilter(null),
                    ),
                
                    const SizedBox(width: 24),
                    // Activity type tabs
                    ...ActivityType.values.map((type) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: _buildUnderlineTab(
                          text: type.displayName,
                          isSelected:
                              historyProvider.selectedFilter == type,
                          onTap: () => historyProvider.setFilter(type),
                        ),
                      );
                    }).toList(),
                     Divider(
                       color: Colors.grey[300],
                       thickness: 1,
                     ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUnderlineTab({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                color:
                    isSelected
                        ? const Color(0xFF333333)
                        : const Color(0xFF999999),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 2,
              width: 24,
              color:
                  isSelected
                      ? const Color(0xFF333333)
                      : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
