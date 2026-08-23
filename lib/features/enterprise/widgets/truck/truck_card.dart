import 'package:flutter/material.dart';

import '../../models/truck_model.dart';

class TruckCard extends StatelessWidget {
  final TruckModel truck;

  const TruckCard({super.key, required this.truck});

  @override
  Widget build(BuildContext context) {
    final activeColor = truck.isActive ? Colors.greenAccent : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff182233),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_shipping,
                color: Colors.cyanAccent,
                size: 32,
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      truck.truckName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      truck.plateNumber,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              Icon(Icons.circle, color: activeColor, size: 14),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              const Icon(Icons.person, color: Colors.orangeAccent, size: 20),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  (truck.assignedDriverId == null ||
                          truck.assignedDriverId!.isEmpty)
                      ? "No Driver Assigned"
                      : truck.assignedDriverId!,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  
                },
                icon: const Icon(Icons.edit, color: Colors.orangeAccent),
              ),

              IconButton(
                onPressed: () {
                  
                },
                icon: const Icon(Icons.delete, color: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
