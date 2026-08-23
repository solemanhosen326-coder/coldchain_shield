import 'package:flutter/material.dart';

class TripStatusBadge extends StatelessWidget {
  final String status;

  const TripStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool running = status == "running";

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: running ? Colors.green : Colors.blueGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        running ? "RUNNING" : "COMPLETED",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}