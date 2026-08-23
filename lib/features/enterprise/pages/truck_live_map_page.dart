import 'package:coldchain_shield/features/enterprise/enterprise_provider.dart';
import 'package:coldchain_shield/features/enterprise/models/trip_packet_model.dart';
import 'package:coldchain_shield/features/enterprise/widgets/truck_live_map/animated_truck_marker.dart';
import 'package:coldchain_shield/features/enterprise/widgets/truck_live_map/truck_live_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/trip_route_service.dart';

class TruckLiveMapPage extends StatefulWidget {
  final TripPacketModel trip;

  const TruckLiveMapPage({super.key, required this.trip});

  @override
  State<TruckLiveMapPage> createState() => _TruckLiveMapPageState();
}

class _TruckLiveMapPageState extends State<TruckLiveMapPage> {
  final TripRouteService _routeService = TripRouteService();
  final MapController _mapController = MapController();
  LatLng? _lastCameraPosition;

  void _followTruck(LatLng position) {
    _lastCameraPosition = position;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        _mapController.move(position, _mapController.camera.zoom);
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EnterpriseProvider>();

    final liveTrip = provider.trips.firstWhere(
      (e) => e.truckId == widget.trip.truckId,
      orElse: () => widget.trip,
    );

    final truckPosition = LatLng(liveTrip.latitude, liveTrip.longitude);

    return Scaffold(
      backgroundColor: const Color(0xff0B1220),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(liveTrip.truckId),
      ),

      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: truckPosition, initialZoom: 15),

            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.coldchain_shield",
              ),

              StreamBuilder<Map<String, dynamic>>(
                stream: liveTrip.tripId.isEmpty
                    ? const Stream.empty()
                    : _routeService.getRouteWithStatus(liveTrip.tripId),

                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    debugPrint("❌ Route Error: ${snapshot.error}");
                  }

                  final data = snapshot.data;

                  final List<LatLng> route =
                      data?["route"] as List<LatLng>? ?? [];

                  final String status =
                      data?["status"]?.toString() ?? "unknown";

                  final bool hasRoute = route.isNotEmpty;

                  final LatLng? startPoint = hasRoute ? route.first : null;

                  final LatLng? endPoint =
                      status == "completed" && route.length >= 2
                      ? route.last
                      : null;

                  debugPrint("Route Trip ID: '${liveTrip.tripId}'");

                  debugPrint("Route Points: ${route.length}");

                  return Stack(
                    children: [
                      // =========================
                      // ROUTE
                      // =========================
                      PolylineLayer(
                        polylines: [
                          if (route.length >= 2)
                            Polyline(
                              points: route,
                              strokeWidth: 5,
                              color: Colors.cyanAccent,
                            ),
                        ],
                      ),

                      // =========================
                      // START POINT
                      // =========================
                      if (startPoint != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: startPoint,
                              width: 26,
                              height: 26,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                      color: Colors.black45,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.flag,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),

                      // =========================
                      // END POINT
                      // =========================
                      if (endPoint != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: endPoint,
                              width: 28,
                              height: 28,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black38,
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 17,
                                ),
                              ),
                            ),
                          ],
                        ),

                      // =========================
                      // ROUTE STATUS CARD
                      // =========================
                      Positioned(
                        left: 16,
                        bottom: 24,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xff0B1220).withOpacity(0.92),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white12),
                            boxShadow: const [
                              BoxShadow(blurRadius: 12, color: Colors.black45),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      color: status == "completed"
                                          ? Colors.redAccent
                                          : Colors.greenAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    status == "completed"
                                        ? "COMPLETED"
                                        : "RUNNING",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 7),

                              // Route points
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.route,
                                    color: Colors.cyanAccent,
                                    size: 16,
                                  ),

                                  const SizedBox(width: 6),

                                  Text(
                                    "${route.length} Route Points",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 5),

                              // Tracking
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    route.length >= 2
                                        ? Icons.gps_fixed
                                        : Icons.gps_not_fixed,
                                    color: route.length >= 2
                                        ? Colors.greenAccent
                                        : Colors.orangeAccent,
                                    size: 16,
                                  ),

                                  const SizedBox(width: 6),

                                  Text(
                                    route.length >= 2
                                        ? "TRACKING ACTIVE"
                                        : "WAITING FOR ROUTE",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // =========================
                      // ONE POINT MESSAGE
                      // =========================
                      if (route.length == 1)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 125,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xff0B1220,
                                ).withOpacity(0.90),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "بانتظار نقطة GPS أخرى لرسم المسار...",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              AnimatedTruckMarker(position: truckPosition),
            ],
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: TruckLiveInfoCard(trip: liveTrip),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 32,
            child: Material(
              color: Colors.transparent,
              child: FloatingActionButton(
                heroTag: "recenter_truck",
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 8,
                onPressed: () {
                  _followTruck(truckPosition);
                },
                child: const Icon(Icons.my_location, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
