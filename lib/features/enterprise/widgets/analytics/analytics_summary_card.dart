import 'package:flutter/material.dart';
import '../../models/analytics_model.dart';

class AnalyticsSummaryCard extends StatelessWidget {
  final AnalyticsModel analytics;

  const AnalyticsSummaryCard({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff182233),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Text(
            "Company Overview",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _item(
                  "Trips",
                  analytics.totalTrips.toString(),
                  Icons.route,
                  Colors.cyanAccent,
                ),
              ),
              Expanded(
                child: _item(
                  "Distance",
                  "${analytics.averageDistanceKm.toStringAsFixed(1)} km",
                  Icons.map,
                  Colors.greenAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _item(
                  "Packets",
                  analytics.totalPackets.toString(),
                  Icons.cloud_done,
                  Colors.orangeAccent,
                ),
              ),
              Expanded(
                child: _item(
                  "Avg Speed",
                  "${analytics.averageSpeed.toStringAsFixed(1)} km/h",
                  Icons.speed,
                  Colors.purpleAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _item(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          title,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}