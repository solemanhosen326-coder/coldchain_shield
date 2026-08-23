import 'package:coldchain_shield/features/enterprise/models/trip_packet_model.dart';
import 'package:flutter/material.dart';

class TruckLocationCard extends StatelessWidget {
  final TripPacketModel trip;
  final VoidCallback? onOpenMap;

  const TruckLocationCard({super.key, required this.trip, this.onOpenMap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff182233),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, color: Colors.cyanAccent),
              SizedBox(width: 8),
              Text(
                "Current Location",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            "Latitude : ${trip.latitude.toStringAsFixed(6)}",
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 8),

          Text(
            "Longitude : ${trip.longitude.toStringAsFixed(6)}",
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onOpenMap,
              icon: const Icon(Icons.map),
              label: const Text("Open Map"),
            ),
          ),
        ],
      ),
    );
  }
}
