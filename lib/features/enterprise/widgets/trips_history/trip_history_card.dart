import 'package:flutter/material.dart';

import '../../models/trip_history_model.dart';
import 'trip_statistics_row.dart';
import 'trip_status_badge.dart';

class TripHistoryCard extends StatelessWidget {
  final TripHistoryModel trip;
  final VoidCallback? onTap;

  const TripHistoryCard({
    super.key,
    required this.trip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff1B1F2A),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [

                  Expanded(
                    child: Text(
                      trip.tripId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  TripStatusBadge(
                    status: trip.status,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TripStatisticsRow(
                driverName: trip.driverName,
                truckId: trip.truckId,
              ),

              const SizedBox(height: 16),

              Text(
                "Started : ${trip.startTime}",
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                trip.endTime == null
                    ? "End : ---"
                    : "End : ${trip.endTime}",
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}