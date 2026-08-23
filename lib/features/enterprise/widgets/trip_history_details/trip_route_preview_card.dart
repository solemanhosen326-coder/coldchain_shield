import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TripRoutePreviewCard extends StatelessWidget {
  final List<LatLng> route;

  const TripRoutePreviewCard({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    // =========================
    // NO ROUTE
    // =========================
    if (route.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: const Color(0xff182233),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: Text(
            "No Route Available",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    // =========================
    // ONE GPS POINT
    // =========================
    if (route.length == 1) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xff182233),
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(Icons.route, color: Colors.cyanAccent),
                  SizedBox(width: 10),
                  Text(
                    "Trip Route",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 260,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: route.first,
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: "com.example.coldchain_shield",
                  ),

                  MarkerLayer(
                    markers: [
                      Marker(
                        point: route.first,
                        width: 45,
                        height: 45,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
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

                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 18, left: 16, right: 16),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xdd0B1220),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Text(
                            "Waiting for another GPS point...",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // =========================
    // MULTI-POINT ROUTE
    // =========================
    final startPoint = route.first;
    final endPoint = route.last;

    final bounds = LatLngBounds.fromPoints(route);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff182233),
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // =========================
          // HEADER
          // =========================
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Icon(Icons.route, color: Colors.cyanAccent),
                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    "Trip Route",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Text(
                  "${route.length} points",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

          // =========================
          // MAP
          // =========================
          SizedBox(
            height: 260,
            child: FlutterMap(
              options: MapOptions(
                initialCameraFit: CameraFit.bounds(
                  bounds: bounds,
                  padding: const EdgeInsets.all(40),
                ),
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),

              children: [
                // =========================
                // MAP TILES
                // =========================
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: "com.example.coldchain_shield",
                ),

                // =========================
                // ROUTE
                // =========================
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: route,
                      color: Colors.cyanAccent,
                      strokeWidth: 5,
                    ),
                  ],
                ),

                // =========================
                // START + END
                // =========================
                MarkerLayer(
                  markers: [
                    // START
                    Marker(
                      point: startPoint,
                      width: 45,
                      height: 45,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
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

                    // END
                    Marker(
                      point: endPoint,
                      width: 45,
                      height: 45,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 8,
                              spreadRadius: 2,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
