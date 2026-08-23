import 'package:coldchain_shield/features/enterprise/models/trip_packet_model.dart';
import 'package:flutter/material.dart';

class TruckStatusCards extends StatelessWidget {
  final TripPacketModel trip;

  const TruckStatusCards({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    final overheating = trip.temperature > 8;

    return Row(
      children: [

        Expanded(
          child: _StatusCard(
            icon: Icons.thermostat,
            title: "Temperature",
            value: "${trip.temperature.toStringAsFixed(1)} °C",
            color: overheating
                ? Colors.redAccent
                : Colors.greenAccent,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _StatusCard(
            icon: Icons.speed,
            title: "Speed",
            value: "${trip.speed.toStringAsFixed(1)} km/h",
            color: Colors.cyanAccent,
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatusCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff182233),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [

          Icon(
            icon,
            color: color,
            size: 30,
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}