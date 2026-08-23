import 'package:coldchain_shield/features/enterprise/models/trip_packet_model.dart';
import 'package:flutter/material.dart';

class TruckInformationCard extends StatelessWidget {
  final TripPacketModel trip;

  const TruckInformationCard({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff182233),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [

          _item(Icons.person, "Driver", trip.userName),

          const Divider(color: Colors.white12),

          _item(Icons.phone, "Phone", trip.phone),

          const Divider(color: Colors.white12),

          _item(Icons.email, "Email", trip.email),

          const Divider(color: Colors.white12),

          _item(Icons.access_time, "Last Update", trip.time.toString()),
        ],
      ),
    );
  }

  Widget _item(
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: Colors.cyanAccent,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}