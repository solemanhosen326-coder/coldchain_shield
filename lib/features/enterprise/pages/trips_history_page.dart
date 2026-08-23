import 'package:coldchain_shield/features/enterprise/enterprise_provider.dart';
import 'package:coldchain_shield/features/enterprise/pages/trip_history_details_page.dart';
import 'package:coldchain_shield/features/enterprise/trip_history_provider.dart';
import 'package:coldchain_shield/features/enterprise/widgets/trips_history/trip_history_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TripsHistoryPage extends StatefulWidget {
  const TripsHistoryPage({super.key});

  @override
  State<TripsHistoryPage> createState() => _TripsHistoryPageState();
}

class _TripsHistoryPageState extends State<TripsHistoryPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final enterprise = context.read<EnterpriseProvider>().enterprise;

      if (enterprise != null) {
        await context.read<TripHistoryProvider>().startListening(
          enterprise.companyId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B1220),

      appBar: AppBar(
        title: const Text("Trips History"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Consumer<TripHistoryProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.trips.isEmpty) {
            return const Center(
              child: Text(
                "No Trips Found",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.trips.length,
            itemBuilder: (_, index) {
              return TripHistoryCard(
                trip: provider.trips[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TripHistoryDetailsPage(trip: provider.trips[index]),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
