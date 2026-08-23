import 'package:flutter/material.dart';
import '../../models/analytics_model.dart';

class AnalyticsTripCard extends StatelessWidget {
  final AnalyticsModel analytics;

  const AnalyticsTripCard({
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
          Icons.local_shipping,
          color: Colors.orangeAccent,
        ),
        title: const Text(
          "Trips",
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          "${analytics.totalTrips} Trips",
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}