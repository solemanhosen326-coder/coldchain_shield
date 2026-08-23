import 'package:flutter/material.dart';

import '../../models/trip_packet_model.dart';

class TripPacketsCard extends StatelessWidget {
  final List<TripPacketModel> packets;

  const TripPacketsCard({super.key, required this.packets});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff182233),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          // =========================
          // HEADER
          // =========================
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Icon(Icons.history, color: Colors.cyanAccent),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    "Trip Packets",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),

                // عدد الـ packets
                Text(
                  "${packets.length}",
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Colors.white10),

          // =========================
          // EMPTY STATE
          // =========================
          if (packets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, color: Colors.white38, size: 40),

                  SizedBox(height: 10),

                  Text(
                    "No Packets",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            )
          // =========================
          // PACKETS LIST
          // =========================
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: packets.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Colors.white10),
              itemBuilder: (_, index) {
                final packet = packets[index];

                final bool overheating = packet.temperature > 8;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),

                    // =========================
                    // PACKET ICON
                    // =========================
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: overheating
                            ? Colors.redAccent.withOpacity(0.15)
                            : Colors.cyanAccent.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: overheating
                              ? Colors.redAccent.withOpacity(0.5)
                              : Colors.cyanAccent.withOpacity(0.35),
                        ),
                      ),
                      child: Icon(
                        overheating
                            ? Icons.warning_amber_rounded
                            : Icons.local_shipping,
                        color: overheating
                            ? Colors.redAccent
                            : Colors.cyanAccent,
                        size: 20,
                      ),
                    ),

                    // =========================
                    // TEMPERATURE
                    // =========================
                    title: Row(
                      children: [
                        Text(
                          "${packet.temperature.toStringAsFixed(1)} °C",
                          style: TextStyle(
                            color: overheating
                                ? Colors.redAccent
                                : Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        if (overheating) ...[
                          const SizedBox(width: 8),

                          const Text(
                            "HIGH",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // =========================
                    // DETAILS
                    // =========================
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SPEED
                          Row(
                            children: [
                              const Icon(
                                Icons.speed,
                                color: Colors.white54,
                                size: 14,
                              ),

                              const SizedBox(width: 5),

                              Text(
                                "${packet.speed.toStringAsFixed(1)} km/h",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 3),

                          // LOCATION
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Colors.white54,
                                size: 14,
                              ),

                              const SizedBox(width: 5),

                              Expanded(
                                child: Text(
                                  "${packet.latitude.toStringAsFixed(5)}, "
                                  "${packet.longitude.toStringAsFixed(5)}",
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // =========================
                    // TIME
                    // =========================
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(packet.time),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          "#${index + 1}",
                          style: const TextStyle(
                            color: Colors.white30,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');

    return "$h:$m:$s";
  }
}
