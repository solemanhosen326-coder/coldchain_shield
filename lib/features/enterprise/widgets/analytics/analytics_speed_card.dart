import 'package:flutter/material.dart';
import '../../models/analytics_model.dart';

class AnalyticsSpeedCard extends StatelessWidget {
  final AnalyticsModel analytics;

  const AnalyticsSpeedCard({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff182233),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.speed,
          color: Colors.cyanAccent,
        ),
        title: const Text(
          "Average Speed",
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          "${analytics.averageSpeed.toStringAsFixed(1)} km/h",
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}