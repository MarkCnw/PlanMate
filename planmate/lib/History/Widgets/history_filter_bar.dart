import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:planmate/History/Provider/history_provider.dart';
import 'package:planmate/provider/project_provider.dart';
import 'package:planmate/History/Models/activity_history_model.dart';

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
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF001858),
            ),
          ),
          const SizedBox(height: 8),

          // ---------- Project dropdown ----------
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
                  child: DropdownButton<String?>(
                    value: historyProvider.selectedProjectId,
                    hint: const Text('เลือกโปรเจกต์'),
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    onChanged:
                        (value) => historyProvider.setProjectFilter(value),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All'),
                      ),
                      ...projects.map(
                        (p) => DropdownMenuItem<String?>(
                          value: p.id,
                          child: Text(p.title),
                        ),
                      ),
                    ],
                  ),
                ),
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
