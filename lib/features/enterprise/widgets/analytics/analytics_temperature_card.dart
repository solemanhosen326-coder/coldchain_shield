import 'package:flutter/material.dart';
import '../../models/analytics_model.dart';

class AnalyticsTemperatureCard extends StatelessWidget {
  final AnalyticsModel analytics;

  const AnalyticsTemperatureCard({
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
          Icons.thermostat,
          color: Colors.redAccent,
        ),
        title: const Text(
          "Temperature",
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          "Min : ${analytics.minTemperature.toStringAsFixed(1)}°C\n"
          "Max : ${analytics.maxTemperature.toStringAsFixed(1)}°C",
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}