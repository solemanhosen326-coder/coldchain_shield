import 'package:flutter/material.dart';
import '../../models/trip_statistics_model.dart';

class TripStatisticsCard extends StatelessWidget {
  final TripStatisticsModel statistics;

  const TripStatisticsCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    final duration = statistics.duration;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff182233),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Trip Statistics",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  Icons.schedule,
                  "Duration",
                  _formatDuration(duration),
                  Colors.cyanAccent,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _statCard(
                  Icons.inventory_2,
                  "Packets",
                  statistics.packetsCount.toString(),
                  Colors.orangeAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  Icons.route,
                  "Distance",
                  "${statistics.distanceKm.toStringAsFixed(1)} km",
                  Colors.greenAccent,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _statCard(
                  Icons.speed,
                  "Avg Speed",
                  "${statistics.averageSpeed.toStringAsFixed(1)} km/h",
                  Colors.purpleAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  Icons.thermostat,
                  "Max Temp",
                  "${statistics.maxTemperature.toStringAsFixed(1)} °C",
                  Colors.redAccent,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _statCard(
                  Icons.ac_unit,
                  "Min Temp",
                  "${statistics.minTemperature.toStringAsFixed(1)} °C",
                  Colors.lightBlueAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff1F2C40),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 4),

          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return "${hours}h ${minutes}m";
  }
}
