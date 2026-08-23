import 'package:coldchain_shield/features/enterprise/enterprise_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardStats extends StatelessWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EnterpriseProvider>();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      crossAxisSpacing: 14,
      mainAxisSpacing: 14,

      childAspectRatio: 0.95,

      children: [
        _card(
          "Active Trucks",
          provider.trucksCount.toString(),
          Icons.local_shipping,
          Colors.cyanAccent,
        ),

        _card(
          "Drivers",
          provider.driversCount.toString(),
          Icons.person,
          Colors.greenAccent,
        ),

        _card(
          "Overheating",
          provider.overheatingCount.toString(),
          Icons.warning_amber,
          Colors.redAccent,
        ),

        _card(
          "Packets",
          provider.packetsCount.toString(),
          Icons.cloud_done,
          Colors.orangeAccent,
        ),
      ],
    );
  }

  Widget _card(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xff1B1F2A),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 32),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              maxLines: 1,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
