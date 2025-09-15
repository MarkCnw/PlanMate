import 'package:flutter/material.dart';
import 'package:planmate/History/Models/projec_option_model.dart';
import 'package:provider/provider.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart'; // เพิ่ม import
import 'package:planmate/History/Provider/history_provider.dart';
import 'package:planmate/provider/project_provider.dart';
import 'package:planmate/History/Models/activity_history_model.dart';

// สร้าง model สำหรับ dropdown

class HistoryFilterBar extends StatefulWidget {
  const HistoryFilterBar({super.key});

  @override
  State<HistoryFilterBar> createState() => _HistoryFilterBarState();
}

class _HistoryFilterBarState extends State<HistoryFilterBar>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // index: 0 = All, 1..n = ActivityType.values
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 1 + ActivityType.values.length,
      vsync: this,
    );

    // sync จาก provider -> tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hp = context.read<HistoryProvider>();
      _tabController.index =
          hp.selectedFilter == null
              ? 0
              : 1 + ActivityType.values.indexOf(hp.selectedFilter!);
    });

    // sync จาก tab -> provider
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final hp = context.read<HistoryProvider>();
      if (_tabController.index == 0) {
        hp.setFilter(null);
      } else {
        hp.setFilter(ActivityType.values[_tabController.index - 1]);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // เผื่อกรณี provider เปลี่ยนจากที่อื่น ให้ตาม index ให้ถูก
    final hp = context.watch<HistoryProvider>();
    final idx =
        hp.selectedFilter == null
            ? 0
            : 1 + ActivityType.values.indexOf(hp.selectedFilter!);
    if (_tabController.index != idx) {
      _tabController.index = idx;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF001858),
            ),
          ),
          const SizedBox(height: 8),

          // ---------- Project dropdown with AnimatedCustomDropdown ----------
          Consumer2<HistoryProvider, ProjectProvider>(
            builder: (context, historyProvider, projectProvider, child) {
              final projects = projectProvider.projects;

              // สร้าง options สำหรับ dropdown
              final options = [
                ProjectOption(id: null, title: 'All'),
                ...projects.map(
                  (project) =>
                      ProjectOption(id: project.id, title: project.title),
                ),
              ];

              // หา selected option
              final selectedOption = options.firstWhere(
                (option) => option.id == historyProvider.selectedProjectId,
                orElse: () => options.first, // default เป็น 'All'
              );

              return CustomDropdown<ProjectOption>(
                hintText: 'เลือกโปรเจกต์',
                items: options,
                initialItem: selectedOption,
                onChanged: (ProjectOption? value) {
                  historyProvider.setProjectFilter(value?.id);
                },
                decoration: CustomDropdownDecoration(
                  
                  closedFillColor: Colors.white,
                  expandedFillColor: Colors.white,
                  closedBorder: Border.all(color: Colors.grey[300]!),
                  expandedBorder: Border.all(
                    color: Colors.grey
                  ),
                  closedBorderRadius: BorderRadius.circular(8),
                  expandedBorderRadius: BorderRadius.circular(8),
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  headerStyle: const TextStyle(
                    color: Color(0xFF001858),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  listItemStyle: const TextStyle(
                    color: Color(0xFF001858),
                    fontSize: 16,
                  ),
                ),
                listItemBuilder: (
                  context,
                  item,
                  isSelected,
                  onItemSelect,
                ) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF8B5CF6).withOpacity(0.1)
                              : Colors.transparent,
                    ),
                    child: Text(
                      item.title,
                      style: TextStyle(
                        color:
                            isSelected
                                ? const Color(0xFF8B5CF6)
                                : const Color(0xFF001858),
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  );
                },
                headerBuilder: (context, selectedItem, enabled) {
                  return Container(
                    padding: const EdgeInsets.symmetric(),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedItem.title,
                            style: TextStyle(
                              color:
                                  enabled
                                      ? const Color(0xFF001858)
                                      : Colors.grey[400],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Icon(
                        //   Icons.keyboard_arrow_down,
                        //   color:
                        //       enabled
                        //           ? const Color(0xFF666666)
                        //           : Colors.grey[400],
                        //   size: 20,
                        // ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 16),

          // ---------- Tabs ด้วย TabBar (ดูเท่ากันจริง) ----------
          Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              dividerColor: Colors.grey[300], // เส้นจางใต้แท็บ (baseline)
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: false, // ทุกช่องกว้างเท่ากัน
              indicatorSize:
                  TabBarIndicatorSize
                      .tab, // indicator เต็มความกว้างของช่อง
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(width: 2, color: Color(0xFF333333)),
                insets: EdgeInsets.zero,
              ),
              labelColor: const Color(0xFF333333),
              unselectedLabelColor: const Color(0xFF999999),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
              labelPadding: EdgeInsets.zero, // ให้กินพื้นที่เท่ากันเป๊ะ
              indicatorPadding:
                  EdgeInsets.zero, // indicator ชิดขอบซ้าย/ขวาช่อง
              tabs: [
                const Tab(text: 'All'),
                ...ActivityType.values.map(
                  (e) => Tab(text: e.displayName),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
