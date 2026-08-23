import 'package:flutter/material.dart';

class TripStatisticsRow extends StatelessWidget {
  final String driverName;
  final String truckId;

  const TripStatisticsRow({
    super.key,
    required this.driverName,
    required this.truckId,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        const Icon(
          Icons.person,
          color: Colors.cyanAccent,
          size: 18,
        ),

        const SizedBox(width: 6),

        Expanded(
          child: Text(
            driverName,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ),

        const Icon(
          Icons.local_shipping,
          color: Colors.orangeAccent,
          size: 18,
        ),

        const SizedBox(width: 6),

        Text(
          truckId,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}