import 'package:flutter/material.dart';
import '../../models/trip_history_model.dart';

class TripSummaryCard extends StatelessWidget {
  final TripHistoryModel trip;

  const TripSummaryCard({
    super.key,
    required this.trip,
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
          _item(
            Icons.local_shipping,
            "Truck",
            trip.truckId,
          ),

          const Divider(color: Colors.white12),

          _item(
            Icons.person,
            "Driver",
            trip.driverName,
          ),

          const Divider(color: Colors.white12),

          _item(
            Icons.play_circle_fill,
            "Started",
            trip.startTime.toString(),
          ),

          const Divider(color: Colors.white12),

          _item(
            Icons.stop_circle,
            "Finished",
            trip.endTime == null
                ? "Running"
                : trip.endTime.toString(),
          ),

          const Divider(color: Colors.white12),

          _item(
            Icons.info,
            "Status",
            trip.status.toUpperCase(),
          ),
        ],
      ),
    );
  }

  Widget _item(
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: Colors.cyanAccent,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}