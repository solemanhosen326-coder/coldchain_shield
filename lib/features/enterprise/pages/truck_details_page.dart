import 'package:coldchain_shield/features/enterprise/enterprise_provider.dart';
import 'package:coldchain_shield/features/enterprise/pages/truck_live_map_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip_packet_model.dart';
import '../widgets/truck_details/truck_header_card.dart';
import '../widgets/truck_details/truck_status_cards.dart';
import '../widgets/truck_details/truck_location_card.dart';
import '../widgets/truck_details/truck_information_card.dart';

class TruckDetailsPage extends StatelessWidget {
  final TripPacketModel trip;
  const TruckDetailsPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EnterpriseProvider>();

    final liveTrip = provider.trips.firstWhere(
      (e) => e.truckId == trip.truckId,
      orElse: () => trip,
    );

    return Scaffold(
      backgroundColor: const Color(0xff0B1220),

      appBar: AppBar(
        title: Text(liveTrip.truckId),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TruckHeaderCard(trip: liveTrip),
          const SizedBox(height: 20),

          TruckStatusCards(trip: liveTrip),
          const SizedBox(height: 20),

          TruckLocationCard(
            trip: liveTrip,
            onOpenMap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TruckLiveMapPage(trip: liveTrip),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          TruckInformationCard(trip: liveTrip),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
