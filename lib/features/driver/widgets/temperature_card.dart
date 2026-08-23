import 'package:coldchain_shield/features/driver/trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TemperatureCard extends StatelessWidget {
  // final bool isActive;

  const TemperatureCard({super.key});

  @override
  Widget build(BuildContext context) {
    const Color crystalBlue = Color(0xFF00E5FF);
    const Color neonRed = Color(0xFFFF1744);

    return Selector<TripProvider, double>(
      selector: (context, provider) => provider.currentTemperature,
      builder: (context, currentTemperature, child) {
        bool isOverheated = currentTemperature > 8.0;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30),
          margin: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: (isOverheated ? neonRed : crystalBlue).withValues(
                alpha: 0.18,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: (isOverheated ? neonRed : crystalBlue).withValues(
                  alpha: 0.08,
                ),
                blurRadius: 25,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                isOverheated ? Icons.sensors : Icons.ac_unit_rounded,
                size: 40,
                color: isOverheated ? neonRed : crystalBlue,
              ),

              const SizedBox(height: 15),

              Text(
                "${currentTemperature.toStringAsFixed(1)} °C",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                isOverheated ? "تحذير في الحرارة" : "التبريد مستقر",
                style: TextStyle(
                  color: isOverheated ? neonRed : Colors.grey,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: crystalBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: crystalBlue.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: crystalBlue, size: 18),
                    SizedBox(width: 6),
                    Text(
                      isOverheated ? "Cooling Failure" : "Cooling Quality",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
