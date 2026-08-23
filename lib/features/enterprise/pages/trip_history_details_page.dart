import 'package:coldchain_shield/features/enterprise/services/trip_statistics_service.dart';
import 'package:coldchain_shield/features/enterprise/trip_packets_provider.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/trip_history_model.dart';
import '../widgets/trip_history_details/trip_summary_card.dart';
import '../widgets/trip_history_details/trip_statistics_card.dart';
import '../widgets/trip_history_details/trip_route_preview_card.dart';
import '../widgets/trip_history_details/trip_packets_card.dart';

// Reports
import 'package:coldchain_shield/features/reports/pages/trip_report_page.dart';

class TripHistoryDetailsPage extends StatefulWidget {
  final TripHistoryModel trip;

  const TripHistoryDetailsPage({
    super.key,
    required this.trip,
  });

  @override
  State<TripHistoryDetailsPage> createState() =>
      _TripHistoryDetailsPageState();
}

class _TripHistoryDetailsPageState
    extends State<TripHistoryDetailsPage> {
  late TripPacketsProvider _packetsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _packetsProvider = context.read<TripPacketsProvider>();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _packetsProvider.startListening(widget.trip.tripId);
    });
  }

  @override
  void dispose() {
    _packetsProvider.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xff0B1220);
    const cyan = Color(0xff00E5FF);

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.trip.truckId,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          // ============================================================
          // Trip Summary
          // ============================================================

          TripSummaryCard(
            trip: widget.trip,
          ),

          const SizedBox(height: 20),

          // ============================================================
          // Statistics
          // ============================================================

          Consumer<TripPacketsProvider>(
            builder: (_, provider, __) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (provider.packets.isEmpty) {
                return const SizedBox();
              }

              final statistics =
                  TripStatisticsService().calculateStatistics(
                provider.packets,
              );

              return TripStatisticsCard(
                statistics: statistics,
              );
            },
          ),

          const SizedBox(height: 20),

          // ============================================================
          // Route Preview
          // ============================================================

          Consumer<TripPacketsProvider>(
            builder: (_, provider, __) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (provider.packets.isEmpty) {
                return const SizedBox();
              }

              final route = provider.packets
                  .map(
                    (e) => LatLng(
                      e.latitude,
                      e.longitude,
                    ),
                  )
                  .toList();

              return TripRoutePreviewCard(
                route: route,
              );
            },
          ),

          const SizedBox(height: 20),

          // ============================================================
          // Trip Packets
          // ============================================================

          Consumer<TripPacketsProvider>(
            builder: (_, provider, __) {
              if (provider.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return TripPacketsCard(
                packets: provider.packets,
              );
            },
          ),

          const SizedBox(height: 30),

          // ============================================================
          // Generate Report
          // ============================================================

          SizedBox(
            width: double.infinity,

            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TripReportPage(
                      tripId: widget.trip.tripId,
                    ),
                  ),
                );
              },

              icon: const Icon(
                Icons.picture_as_pdf_outlined,
              ),

              label: const Text(
                "إنشاء تقرير الرحلة",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: cyan,
                foregroundColor: Colors.black,

                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}


