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
      color: Colors.white, // ✅ ใช้ color แทน decoration
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity Type Filters
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
                  color: Colors.white, // ✅ เพิ่มพื้นหลังสีขาว
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: historyProvider.selectedProjectId,
                    hint: const Text('เลือกโปรเจกต์'),
                    isExpanded: true,
                    dropdownColor:
                        Colors.white, // ✅ เพิ่มสีพื้นหลัง dropdown
                    onChanged: (value) {
                      historyProvider.setProjectFilter(value);
                    },
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('ทั้งหมด'),
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

          // Project Filter
          const Text(
            'Activitis type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF001858),
            ),
          ),
          const SizedBox(height: 8),
          Consumer<HistoryProvider>(
            builder: (context, historyProvider, child) {
              return Wrap(
                spacing: 8,
                children: [
                  // All filter
                  FilterChip(
                    label: const Text('ทั้งหมด'),
                    selected: historyProvider.selectedFilter == null,
                    onSelected: (selected) {
                      if (selected) {
                        historyProvider.setFilter(null);
                      }
                    },
                    selectedColor: const Color(
                      0xFF8B5CF6,
                    ).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF8B5CF6),
                    backgroundColor: Colors.white, // ✅ เพิ่มพื้นหลังสีขาว
                  ),
                  // Activity type filters
                  ...ActivityType.values.map((type) {
                    return FilterChip(
                      label: Text(type.displayName),
                      selected: historyProvider.selectedFilter == type,
                      onSelected: (selected) {
                        historyProvider.setFilter(selected ? type : null);
                      },
                      selectedColor: _getTypeColor(type).withOpacity(0.2),
                      checkmarkColor: _getTypeColor(type),
                      backgroundColor:
                          Colors.white, // ✅ เพิ่มพื้นหลังสีขาว
                    );
                  }).toList(),
                ],
              );
            },
          ),

          // Clear filters button
          Consumer<HistoryProvider>(
            builder: (context, historyProvider, child) {
              if (historyProvider.selectedFilter == null &&
                  historyProvider.selectedProjectId == null) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextButton.icon(
                  onPressed: historyProvider.clearFilters,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('ล้างตัวกรอง'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8B5CF6),
                    backgroundColor: Colors.white, // ✅ เพิ่มพื้นหลังสีขาว
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(ActivityType type) {
    switch (type) {
      case ActivityType.create:
        return Colors.green;
      case ActivityType.update:
        return Colors.blue;
      case ActivityType.complete:
        return Colors.orange;
      case ActivityType.delete:
        return Colors.red;
    }
  }
}
