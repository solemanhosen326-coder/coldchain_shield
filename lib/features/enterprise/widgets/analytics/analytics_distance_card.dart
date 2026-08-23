import 'package:flutter/material.dart';
import '../../models/analytics_model.dart';

class AnalyticsDistanceCard extends StatelessWidget {
  final AnalyticsModel analytics;

  const AnalyticsDistanceCard({
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
          Icons.route,
          color: Colors.greenAccent,
        ),
        title: const Text(
          "Total Distance",
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          "${analytics.averageDistanceKm.toStringAsFixed(1)} km",
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}