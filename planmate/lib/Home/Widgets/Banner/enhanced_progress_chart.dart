import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:planmate/Models/task_model.dart';
import 'package:planmate/provider/project_provider.dart';
import 'package:planmate/provider/task_provider.dart';
import 'package:provider/provider.dart';

class EnhancedProgressChartSection extends StatefulWidget {
  const EnhancedProgressChartSection({super.key});

  @override
  State<EnhancedProgressChartSection> createState() => _EnhancedProgressChartSectionState();
}

class _EnhancedProgressChartSectionState extends State<EnhancedProgressChartSection> {
  bool isLoading = true;
  List<DailyProgress> weeklyData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
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
      weeklyData = _generateWeeklyData(allTasks);
      
    } catch (e) {
      print('Error loading chart data: $e');
      // Fallback to sample data
      weeklyData = _getSampleData();
    }
    
    setState(() => isLoading = false);
  }

  List<DailyProgress> _generateWeeklyData(List<TaskModel> tasks) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    List<DailyProgress> data = [];
    
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dayName = _getDayName(i);
      
      // Count tasks planned and completed for this day
      int planned = 0;
      int completed = 0;
      
      for (final task in tasks) {
        // Check if task was created this week (planned)
        if (_isSameDay(task.createdAt, date)) {
          planned++;
        }
        
        // Check if task was completed on this day
        if (task.isDone && task.completedAt != null && _isSameDay(task.completedAt!, date)) {
          completed++;
        }
        
        // For tasks due today, count as planned
        if (task.hasDueDate && _isSameDay(task.dueDate!, date)) {
          planned++;
        }
      }
      
      data.add(DailyProgress(
        day: dayName,
        dayIndex: i,
        planned: planned.toDouble(),
        completed: completed.toDouble(),
        date: date,
      ));
    }
    
    return data;
  }

  List<DailyProgress> _getSampleData() {
    return [
      DailyProgress(day: 'Mo', dayIndex: 0, planned: 4, completed: 6, date: DateTime.now()),
      DailyProgress(day: 'Tu', dayIndex: 1, planned: 3, completed: 5, date: DateTime.now()),
      DailyProgress(day: 'We', dayIndex: 2, planned: 4, completed: 3, date: DateTime.now()),
      DailyProgress(day: 'Th', dayIndex: 3, planned: 5, completed: 6, date: DateTime.now()),
      DailyProgress(day: 'Fr', dayIndex: 4, planned: 3, completed: 7, date: DateTime.now()),
      DailyProgress(day: 'Sa', dayIndex: 5, planned: 2, completed: 4, date: DateTime.now()),
      DailyProgress(day: 'Su', dayIndex: 6, planned: 3, completed: 2, date: DateTime.now()),
    ];
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  String _getDayName(int index) {
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return days[index];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            if (isLoading)
              _buildLoadingState()
            else
              _buildChart(),
            const SizedBox(height: 16),
            _buildLegend(),
            const SizedBox(height: 12),
            _buildStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Progress',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF001858),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Weekly task completion',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            // Navigate to detailed progress screen
            _showDetailedProgress();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'See Detail',
              style: TextStyle(
                color: Color(0xFF8B5CF6),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (weeklyData.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'No data available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Start creating tasks to see your progress',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: _getMaxY(),
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            horizontalInterval: _getMaxY() / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: _getMaxY() / 4,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= weeklyData.length) {
                    return const SizedBox.shrink();
                  }

                  final data = weeklyData[index];
                  final isToday = _isToday(data.date);
                  
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: [
                        Text(
                          data.day,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                            color: isToday ? const Color(0xFF8B5CF6) : Colors.grey[700],
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(height: 2),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFF8B5CF6),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: _buildBarGroups(),
          barTouchData: BarTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: const Color(0xFF2D3748), // ✅ ใช้ชื่อใหม่
              tooltipRoundedRadius: 12,
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final data = weeklyData[group.x];
                final isPlanned = rodIndex == 0;
                final value = isPlanned ? data.planned : data.completed;
                final label = isPlanned ? 'Planned' : 'Completed';
                
                return BarTooltipItem(
                  '$label: ${value.toInt()}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  double _getMaxY() {
    if (weeklyData.isEmpty) return 10;
    
    double max = 0;
    for (final data in weeklyData) {
      if (data.planned > max) max = data.planned;
      if (data.completed > max) max = data.completed;
    }
    
    // Add some padding and round up to nearest 5
    max = (max * 1.2).ceilToDouble();
    return (max / 5).ceil() * 5;
  }

  List<BarChartGroupData> _buildBarGroups() {
    return weeklyData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.planned,
            width: 14,
            color: const Color(0xFFE2E8F0),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
          ),
          BarChartRodData(
            toY: data.completed,
            width: 14,
            color: const Color(0xFF8B5CF6),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(0xFF8B5CF6),
                Color(0xFFA78BFA),
              ],
            ),
          ),
        ],
        barsSpace: 3,
      );
    }).toList();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          color: const Color(0xFFE2E8F0),
          label: 'Planned',
          icon: Icons.schedule,
        ),
        const SizedBox(width: 24),
        _buildLegendItem(
          color: const Color(0xFF8B5CF6),
          label: 'Completed',
          icon: Icons.check_circle,
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    if (weeklyData.isEmpty) return const SizedBox.shrink();

    final totalPlanned = weeklyData.fold<double>(0, (sum, data) => sum + data.planned);
    final totalCompleted = weeklyData.fold<double>(0, (sum, data) => sum + data.completed);
    final completionRate = totalPlanned > 0 ? (totalCompleted / totalPlanned * 100) : 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'This Week',
            '${totalCompleted.toInt()}/${totalPlanned.toInt()}',
            Icons.assignment_turned_in,
            const Color(0xFF8B5CF6),
          ),
          Container(
            width: 1,
            height: 32,
            color: Colors.grey[300],
          ),
          _buildStatItem(
            'Completion Rate',
            '${completionRate.toStringAsFixed(0)}%',
            Icons.trending_up,
            completionRate >= 80 ? Colors.green : 
            completionRate >= 60 ? Colors.orange : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showDetailedProgress() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Weekly Progress Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF001858),
                ),
              ),
              const SizedBox(height: 20),
              ...weeklyData.map((data) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data.day,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '${data.completed.toInt()}/${data.planned.toInt()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
              )).toList(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DailyProgress {
  final String day;
  final int dayIndex;
  final double planned;
  final double completed;
  final DateTime date;

  DailyProgress({
    required this.day,
    required this.dayIndex,
    required this.planned,
    required this.completed,
    required this.date,
  });
}