import 'package:flutter/material.dart';
import '../models/trip_packet_model.dart';

class FleetCard extends StatelessWidget {
  final TripPacketModel trip;
  final VoidCallback? onTap;

  const FleetCard({super.key, required this.trip, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool overheating = trip.temperature > 8;
    final bool online = DateTime.now().difference(trip.time).inMinutes < 2;
    Color speedColor;

    if (trip.speed < 5) {
      speedColor = Colors.grey;
    } else if (trip.speed < 60) {
      speedColor = Colors.greenAccent;
    } else {
      speedColor = Colors.orangeAccent;
    }
    return Card(
      color: overheating
    ? const Color(0xff2A1B1B)
    : const Color(0xFF1B1F2A),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: overheating ? Colors.redAccent : Colors.cyanAccent,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.local_shipping, color: Colors.white),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      trip.truckId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: online ? Colors.green : Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      online ? "ONLINE" : "OFFLINE",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    trip.userName,
                    style: TextStyle(
                      color: speedColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "${trip.speed.toStringAsFixed(1)} km/h",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${trip.temperature.toStringAsFixed(1)} °C",
                    style: TextStyle(
                      color: overheating ? Colors.redAccent : Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "${trip.latitude.toStringAsFixed(4)}, ${trip.longitude.toStringAsFixed(4)}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Updated ${trip.time.hour.toString().padLeft(2, '0')}:${trip.time.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
