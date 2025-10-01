import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:planmate/Home/widgets/Banner/legend_widget.dart';

class ProgressChartSection extends StatelessWidget {
  const ProgressChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + See Detail
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Your Progress',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'See Detail',
              style: TextStyle(color: Colors.blue),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Chart container
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          width: double.infinity,
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: 10,
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(),
                rightTitles: AxisTitles(),
                topTitles: AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          days[value.toInt()],
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
              ),
              barGroups: [
                makeGroup(0, 4, 6),
                makeGroup(1, 3, 5),
                makeGroup(2, 4, 3),
                makeGroup(3, 5, 6),
                makeGroup(4, 3, 7),
                makeGroup(5, 2, 4),
              ],
              barTouchData: BarTouchData(enabled: false),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Legend(color: Color(0xFFCBD5E1), label: 'Planned'),
            SizedBox(width: 20),
            Legend(color: Color(0xFF60A5FA), label: 'Completed'),
          ],
        ),
      ],
    );
  }

  // Helper function
  BarChartGroupData makeGroup(int x, double planned, double completed) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: planned,
          width: 8,
          color: const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.zero,
        ),
        BarChartRodData(
          toY: completed,
          width: 8,
          color: const Color(0xFF60A5FA),
          borderRadius: BorderRadius.zero,
        ),
      ],
      barsSpace: 4,
    );
  }
}
