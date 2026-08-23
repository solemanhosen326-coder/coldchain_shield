import 'package:coldchain_shield/constants/app_constants.dart';
import 'package:coldchain_shield/features/driver/trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TripStatusCard extends StatelessWidget {
  const TripStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, provider, child) {
        final isTripActive = provider.isTripActive;
        final connectionStatus = provider.connectionStatus;
        final syncStatus = provider.syncStatus;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .04),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.crystalBlue.withValues(alpha: .15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.crystalBlue.withValues(alpha: .10),
                ),
                child: Icon(
                  isTripActive
                      ? Icons.local_shipping_rounded
                      : Icons.pause_circle_outline,
                  color: isTripActive
                      ? Colors.greenAccent
                      : AppColors.crystalBlue,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Current Trip",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "Cold Supply Mission",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      isTripActive
                          ? "Status : In Progress"
                          : "Status : Waiting to Start",
                      style: TextStyle(
                        color: isTripActive
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          connectionStatus == "ONLINE"
                              ? Icons.wifi
                              : Icons.wifi_off,
                          color: connectionStatus == "ONLINE"
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          size: 15,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          connectionStatus,
                          style: TextStyle(
                            color: connectionStatus == "ONLINE"
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(width: 15),

                        AnimatedRotation(
                          turns: syncStatus == "SYNCING" ? 1 : 0,
                          duration: const Duration(seconds: 1),
                          child: Icon(
                            Icons.sync,
                            color: switch (syncStatus) {
                              "SYNCED" => Colors.greenAccent,
                              "SYNCING" => Colors.orangeAccent,
                              "FAILED" => Colors.redAccent,
                              _ => Colors.grey,
                            },
                            size: 15,
                          ),
                        ),

                        const SizedBox(width: 6),

                        Text(
                          syncStatus,
                          style: TextStyle(
                            color: switch (syncStatus) {
                              "SYNCED" => Colors.greenAccent,
                              "SYNCING" => Colors.orangeAccent,
                              "FAILED" => Colors.redAccent,
                              _ => Colors.grey,
                            },
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white38,
                size: 18,
              ),
            ],
          ),
        );
      },
    );
  }
}
