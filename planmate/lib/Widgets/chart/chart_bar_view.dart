import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:planmate/Utils/date_utils.dart';
import 'package:planmate/models/daily_progress_model.dart';

class ChartBarView extends StatelessWidget {
  final List<DailyProgress> weeklyData;
  final Animation<double> chartAnimation;

  const ChartBarView({
    super.key,
    required this.weeklyData,
    required this.chartAnimation,
  });

  @override
  Widget build(BuildContext context) {
    if (weeklyData.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    return AnimatedBuilder(
      animation: chartAnimation,
      builder: (context, child) {
        return BarChart(
          BarChartData(
            maxY: _getMaxY(),
            alignment: BarChartAlignment.spaceAround,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 5,
              getDrawingHorizontalLine:
                  (value) => FlLine(
                    color: const Color(0xFF8B5CF6).withOpacity(0.08),
                    strokeWidth: 1.2,
                  ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 42,
                  interval: 5,
                  getTitlesWidget: (value, meta) {
                    // แสดงเฉพาะเลขที่หาร 5 ลงตัว
                    if (value < 0 || value % 5 != 0)
                      return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        value.toInt().toString(),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
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
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= weeklyData.length) {
                      return const SizedBox.shrink();
                    }

                    final data = weeklyData[index];
                    final isToday = data.date.isToday;

                    return Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isToday
                                  ? const Color(0xFF8B5CF6)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          data.day,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color:
                                isToday
                                    ? Colors.white
                                    : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: _buildBarGroups(chartAnimation.value),
            barTouchData: BarTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => const Color(0xFF2D3748),
                tooltipRoundedRadius: 12,
                tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
        );
      },
    );
  }

  /// หาค่าสูงสุดของ Y (ปรับให้เป็นเลขกลมๆ)
  double _getMaxY() {
    if (weeklyData.isEmpty) return 10;
    double max = 0;
    for (final data in weeklyData) {
      if (data.planned > max) max = data.planned;
      if (data.completed > max) max = data.completed;
    }

    // ปัดเป็นเลขกลมๆ (5, 10, 15, 20...)
    if (max == 0) return 10;
    final roundedMax = ((max / 5).ceil() * 5).toDouble();
    return roundedMax;
  }

  /// สร้างแท่ง bar
  List<BarChartGroupData> _buildBarGroups(double animationValue) {
    return weeklyData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.planned * animationValue,
            width: 13,
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.grey.shade300, Colors.grey.shade200],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
          BarChartRodData(
            toY: data.completed * animationValue,
            width: 13,
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
        barsSpace: 4,
      );
    }).toList();
  }
}
