import 'package:coldchain_shield/features/driver/trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TripStatistics extends StatelessWidget {
  const TripStatistics({super.key});

  static const Color crystalBlue = Color(0xFF00E5FF);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Selector<TripProvider, double>(
            selector: (context, provider) => provider.currentSpeedKmH,
            builder: (context, currentSpeedKmH, child) {
              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: crystalBlue.withValues(alpha: .18)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.speed_rounded,
                      color: Color(0xFF00E5FF),
                      size: 28,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "${(currentSpeedKmH).toStringAsFixed(1)} km/h",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Current Speed",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Selector<TripProvider, int>(
            selector: (context, provider) => provider.cachedPacketsCount,
            builder: (context, cachedPacketsCount, child) {
              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: crystalBlue.withValues(alpha: .18)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.cloud_upload_rounded,
                      color: Color(0xFF00E5FF),
                      size: 28,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      cachedPacketsCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Cached Packets",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
