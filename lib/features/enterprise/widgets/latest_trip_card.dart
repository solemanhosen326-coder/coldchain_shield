import 'package:coldchain_shield/features/enterprise/enterprise_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LatestTripCard extends StatelessWidget {
  const LatestTripCard({super.key});

  @override
  Widget build(BuildContext context) {
    const crystalBlue = Color(0xFF00E5FF);

    return Selector<EnterpriseProvider, dynamic>(
      selector: (_, provider) => provider.latestPacket,
      builder: (_, packet, __) {
        if (packet == null) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .04),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                "No Active Trips",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: crystalBlue.withValues(alpha: .20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Latest Update",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [

                  const Icon(
                    Icons.local_shipping,
                    color: Colors.white,
                  ),

                  const SizedBox(width: 10),

                  Text(
                    packet.truckId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    "${packet.temperature.toStringAsFixed(1)} °C",
                    style: TextStyle(
                      color: packet.temperature > 8
                          ? Colors.redAccent
                          : Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Text(
                "Driver : ${packet.uid}",
                style: const TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 6),

              Text(
                "Speed : ${packet.speed.toStringAsFixed(1)} km/h",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        );
      },
    );
  }
}