import 'package:coldchain_shield/features/enterprise/enterprise_provider.dart';
import 'package:coldchain_shield/features/enterprise/models/trip_packet_model.dart';
import 'package:coldchain_shield/features/enterprise/pages/truck_details_page.dart';
import 'package:coldchain_shield/features/enterprise/widgets/fleet_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FleetList extends StatelessWidget {
  const FleetList({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<EnterpriseProvider, List<TripPacketModel>>(
      selector: (_, provider) => provider.trips,
      builder: (_, trips, __) {
        if (trips.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(30),
            alignment: Alignment.center,
            child: const Text(
              "No Active Trucks",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trips.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, index) {
            final trip = trips[index];

            return FleetCard(
              trip: trip,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TruckDetailsPage(
                      trip: trip,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}