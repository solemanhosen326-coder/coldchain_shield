import 'package:flutter/material.dart';
import '../../models/trip_packet_model.dart';

class TruckHeaderCard extends StatelessWidget {
  final TripPacketModel trip;

  const TruckHeaderCard({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    final bool online =
        DateTime.now().difference(trip.time).inMinutes < 2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff1B1F2A),
        borderRadius: BorderRadius.circular(22),
      ),

      child: Row(
        children: [

          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.cyanAccent.withOpacity(.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.local_shipping,
              color: Colors.cyanAccent,
              size: 34,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  trip.truckId,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  trip.userName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [

                    Icon(
                      Icons.circle,
                      size: 10,
                      color: online
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      online ? "ONLINE" : "OFFLINE",
                      style: TextStyle(
                        color: online
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.refresh,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}