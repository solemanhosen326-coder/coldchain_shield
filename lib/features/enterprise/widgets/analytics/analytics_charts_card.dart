import 'package:coldchain_shield/features/enterprise/widgets/analytics/analytics_chart_model.dart';
import 'package:coldchain_shield/features/enterprise/widgets/analytics/analytics_chart_point.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsChartsCard extends StatelessWidget {
  final AnalyticsChartModel charts;

  const AnalyticsChartsCard({super.key, required this.charts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff182233),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =========================
          // Temperature
          // =========================
          const Text(
            "Average Temperature History",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          _buildLineChart(points: charts.temperature, color: Colors.redAccent),

          // =========================
          // Speed
          // =========================
          const SizedBox(height: 30),

          const Text(
            "Speed History",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          _buildLineChart(points: charts.speed, color: Colors.blueAccent),

          // =========================
          // Distance
          // =========================
          const SizedBox(height: 30),

          const Text(
            "Distance History",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          _buildLineChart(points: charts.distance, color: Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _buildLineChart({
    required List<AnalyticsChartPoint> points,
    required Color color,
  }) {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),

          borderData: FlBorderData(show: true),

          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index < 0 || index >= charts.temperature.length) {
                    return const SizedBox.shrink();
                  }

                  return Text(
                    charts.temperature[index].label,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  );
                },
              ),
            ),

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),

          lineBarsData: [
            LineChartBarData(
              isCurved: true,

              spots: points.map((e) => FlSpot(e.x, e.y)).toList(),

              barWidth: 4,

              dotData: const FlDotData(show: true),

              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
