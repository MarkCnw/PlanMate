import 'package:flutter/material.dart';
import 'package:planmate/models/daily_progress_model.dart';
import 'package:planmate/models/task_model.dart';
import 'package:planmate/Utils/progress_utils.dart';
import 'package:planmate/provider/project_provider.dart';
import 'package:planmate/provider/task_provider.dart';
import 'package:planmate/widgets/chart/chart_container.dart';
import 'package:provider/provider.dart';

class EnhancedProgressChartSection extends StatefulWidget {
  const EnhancedProgressChartSection({super.key});

  @override
  State<EnhancedProgressChartSection> createState() =>
      _EnhancedProgressChartSectionState();
}

class _EnhancedProgressChartSectionState
    extends State<EnhancedProgressChartSection>
    with TickerProviderStateMixin {
  bool isLoading = true;
  List<DailyProgress> weeklyData = [];
  late AnimationController _chartController;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();

    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _chartAnimation = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutBack,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      final projectProvider = context.read<ProjectProvider>();
      final taskProvider = context.read<TaskProvider>();

      // Get all projects
      final projects = projectProvider.projects;

      // Collect all tasks from all projects
      List<TaskModel> allTasks = [];
      for (final project in projects) {
        final tasks = taskProvider.getProjectTasks(project.id);
        allTasks.addAll(tasks);
      }

      // Generate weekly progress data
      weeklyData = generateWeeklyData(allTasks);
    } catch (e) {
      print('Error loading chart data: $e');
      // Fallback to sample data
      weeklyData = getSampleData();
    }
    if (mounted) {
      setState(() => isLoading = false);
      _chartController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.read<ProjectProvider>();
    final taskProvider = context.watch<TaskProvider>();

    return FutureBuilder(
      future: _prepareData(projectProvider, taskProvider),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildPremiumLoadingState();
        }
        return ChartContainer(
          isLoading: isLoading,
          weeklyData: weeklyData,
          onDetailsTap: _showDetailedProgress,
          chartAnimation: _chartAnimation,
        );
      },
    );
  }

  /// ✅ สร้าง method _prepareData
  Future<void> _prepareData(
    ProjectProvider projectProvider,
    TaskProvider taskProvider,
  ) async {
    await _loadData(); // ใช้ method เดิมที่คุณเขียนแล้ว
  }

  Widget _buildPremiumLoadingState() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade50, Colors.grey.shade100],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading your progress...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailedProgress() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 400,
                maxHeight: 500,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFFAFAFA)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.insights_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Weekly Progress Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: weeklyData.length,
                        itemBuilder: (context, index) {
                          final data = weeklyData[index];
                          final completionRate =
                              data.planned > 0
                                  ? (data.completed / data.planned)
                                  : 0.0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey.shade50,
                                  Colors.white,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors:
                                          completionRate >= 1.0
                                              ? [
                                                const Color(0xFF10B981),
                                                const Color(0xFF059669),
                                              ]
                                              : completionRate >= 0.5
                                              ? [
                                                const Color(0xFF8B5CF6),
                                                const Color(0xFF7C3AED),
                                              ]
                                              : [
                                                const Color(0xFFF59E0B),
                                                const Color(0xFFD97706),
                                              ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      data.day,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${data.completed.toInt()}/${data.planned.toInt()} tasks',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1A1A2E),
                                            ),
                                          ),
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                            decoration: BoxDecoration(
                                              color:
                                                  completionRate >= 1.0
                                                      ? const Color(
                                                        0xFF10B981,
                                                      ).withOpacity(0.1)
                                                      : completionRate >=
                                                          0.5
                                                      ? const Color(
                                                        0xFF8B5CF6,
                                                      ).withOpacity(0.1)
                                                      : const Color(
                                                        0xFFF59E0B,
                                                      ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${(completionRate * 100).toInt()}%',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight:
                                                    FontWeight.w700,
                                                color:
                                                    completionRate >= 1.0
                                                        ? const Color(
                                                          0xFF10B981,
                                                        )
                                                        : completionRate >=
                                                            0.5
                                                        ? const Color(
                                                          0xFF8B5CF6,
                                                        )
                                                        : const Color(
                                                          0xFFF59E0B,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      // Progress bar
                                      Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: completionRate
                                              .clamp(0.0, 1.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors:
                                                    completionRate >= 1.0
                                                        ? [
                                                          const Color(
                                                            0xFF10B981,
                                                          ),
                                                          const Color(
                                                            0xFF059669,
                                                          ),
                                                        ]
                                                        : completionRate >=
                                                            0.5
                                                        ? [
                                                          const Color(
                                                            0xFF8B5CF6,
                                                          ),
                                                          const Color(
                                                            0xFF7C3AED,
                                                          ),
                                                        ]
                                                        : [
                                                          const Color(
                                                            0xFFF59E0B,
                                                          ),
                                                          const Color(
                                                            0xFFD97706,
                                                          ),
                                                        ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
