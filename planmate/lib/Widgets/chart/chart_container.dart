import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:planmate/models/daily_progress_model.dart';
import 'package:planmate/widgets/chart/chart_bar_view.dart';

class ChartContainer extends StatelessWidget {
  final bool isLoading;
  final List<DailyProgress> weeklyData;
  final Animation<double> chartAnimation;
  final VoidCallback onDetailsTap;

  const ChartContainer({
    super.key,
    required this.isLoading,
    required this.weeklyData,
    required this.chartAnimation,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
          stops: [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 16),
            spreadRadius: -8,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.08),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPremiumHeader(onDetailsTap),
              const SizedBox(height: 15),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (weeklyData.isEmpty)
                const Text("No data available")
              else
                ChartBarView(
                  weeklyData: weeklyData,
                  chartAnimation: chartAnimation,
                ),
              _buildPremiumLegend(),
              const SizedBox(height: 10),
              _buildPremiumStats(weeklyData),
            ],
          ),
        ),
      ),
    );
  }
}
// ====================
// Helper Widgets
// ====================

Widget _buildPremiumHeader(VoidCallback onDetailsTap) {
  return Row(
    children: [
      const Icon(
        Symbols.bar_chart_4_bars,
        color: Color(0xFF8B5CF6),
        size: 35,
      ),
      const SizedBox(width: 16),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Progress',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Color(0xFF1A1A2E),
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Weekly task completion',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      GestureDetector(
        onTap: onDetailsTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF8B5CF6).withOpacity(0.1),
                const Color(0xFF7C3AED).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.insights_rounded,
                color: Color(0xFF8B5CF6),
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Details',
                style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _buildPremiumLegend() {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPremiumLegendItem(
            gradient: LinearGradient(
              colors: [Colors.grey.shade300, Colors.grey.shade200],
            ),
            label: 'Planned',
          ),
          Container(width: 1, height: 24, color: Colors.grey.shade300),
          _buildPremiumLegendItem(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
            ),
            label: 'Completed',
          ),
        ],
      ),
      const Divider(thickness: 1.2, color: Color(0xFFE0E0E0)),
    ],
  );
}

Widget _buildPremiumLegendItem({
  required Gradient gradient,
  required String label,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ],
  );
}

Widget _buildPremiumStats(List<DailyProgress> weeklyData) {
  if (weeklyData.isEmpty) return const SizedBox.shrink();

  final totalPlanned = weeklyData.fold<double>(
    0,
    (sum, data) => sum + data.planned,
  );
  final totalCompleted = weeklyData.fold<double>(
    0,
    (sum, data) => sum + data.completed,
  );
  final completionRate =
      totalPlanned > 0 ? (totalCompleted / totalPlanned * 100) : 0;

  return Row(
    children: [
      Expanded(
        child: _buildPremiumStatItem(
          'This Week',
          '${totalCompleted.toInt()}/${totalPlanned.toInt()}',
          Icons.assignment_turned_in_rounded,
          const Color(0xFF8B5CF6),
        ),
      ),
      Expanded(
        child: _buildPremiumStatItem(
          'Success Rate',
          '${completionRate.toStringAsFixed(0)}%',
          Icons.trending_up_rounded,
          completionRate >= 80
              ? const Color(0xFF10B981)
              : completionRate >= 60
              ? const Color(0xFFF59E0B)
              : const Color(0xFFEF4444),
        ),
      ),
    ],
  );
}

Widget _buildPremiumStatItem(
  String label,
  String value,
  IconData icon,
  Color color,
) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 26),
      ),
      const SizedBox(height: 10),
      Text(
        value,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ],
  );
}
