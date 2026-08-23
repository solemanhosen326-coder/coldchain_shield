import 'package:flutter/material.dart';
import '../../models/trip_packet_model.dart';

class TruckLiveInfoCard extends StatelessWidget {
  final TripPacketModel trip;

  const TruckLiveInfoCard({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    final overheating = trip.temperature > 8;

    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff182233).withOpacity(.95),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,

        children: [

          Text(
            trip.truckId,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [

              Expanded(
                child: _item(
                  Icons.thermostat,
                  "Temperature",
                  "${trip.temperature.toStringAsFixed(1)} °C",
                  overheating
                      ? Colors.redAccent
                      : Colors.greenAccent,
                ),
              ),

              Expanded(
                child: _item(
                  Icons.speed,
                  "Speed",
                  "${trip.speed.toStringAsFixed(1)} km/h",
                  Colors.cyanAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [

              Expanded(
                child: _item(
                  Icons.person,
                  "Driver",
                  trip.userName,
                  Colors.white,
                ),
              ),

              Expanded(
                child: _item(
                  Icons.access_time,
                  "Updated",
                  trip.time.toString().substring(11,19),
                  Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _item(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Icon(icon, color: color, size: 20),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),

              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}