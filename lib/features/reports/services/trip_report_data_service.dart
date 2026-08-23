import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'package:coldchain_shield/features/driver/services/driver_service.dart';

import '../models/trip_report_model.dart';

class TripReportDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final DriverService _driverService = DriverService();

  // ============================================================
  // Build Trip Report
  // ============================================================

  Future<TripReportModel> buildReport(String tripId) async {
    final tripRef = _firestore.collection("trip_history").doc(tripId);

    // ============================================================
    // Trip document
    // ============================================================

    final tripSnapshot = await tripRef.get();

    if (!tripSnapshot.exists || tripSnapshot.data() == null) {
      throw Exception("Trip not found");
    }

    final trip = tripSnapshot.data()!;

    // ============================================================
    // Company
    // ============================================================

    final String companyId = (trip["companyId"] ?? "").toString();

    String companyName = "";

    if (companyId.isNotEmpty) {
      final enterprise = await _driverService.getEnterpriseData(companyId);

      companyName = enterprise?.companyName ?? "";
    }

    // ============================================================
    // Packets
    // ============================================================

    final packetsSnapshot = await tripRef
        .collection("packets")
        .orderBy("time")
        .get();

    final packets = packetsSnapshot.docs.map((doc) => doc.data()).toList();

    // ============================================================
    // GPS Route
    //
    // IMPORTANT:
    // Firestore packet fields are:
    //     lat
    //     lng
    //
    // We use these SAME fields everywhere.
    // ============================================================

    final List<LatLng> route = [];

    for (final packet in packets) {
      final dynamic rawLat = packet["lat"];

      final dynamic rawLng = packet["lng"];

      if (rawLat == null || rawLng == null) {
        continue;
      }

      final double latitude = (rawLat as num).toDouble();

      final double longitude = (rawLng as num).toDouble();

      // Ignore invalid coordinates.
      if (!latitude.isFinite || !longitude.isFinite) {
        continue;
      }

      if (latitude == 0 && longitude == 0) {
        continue;
      }

      if (latitude < -90 || latitude > 90) {
        continue;
      }

      if (longitude < -180 || longitude > 180) {
        continue;
      }

      route.add(LatLng(latitude, longitude));
    }

    // ============================================================
    // Route debug
    // ============================================================

    debugPrint("🗺️ Valid route points = ${route.length}");

    if (route.isNotEmpty) {
      debugPrint("🟢 First point = ${route.first}");

      debugPrint("🔴 Last point = ${route.last}");
    } else {
      debugPrint("⚠️ No valid GPS route points found");
    }

    // ============================================================
    // Statistics
    // ============================================================

    double totalSpeed = 0;
    double maxSpeed = 0;

    double totalTemperature = 0;

    double minTemperature = double.infinity;

    double maxTemperature = double.negativeInfinity;

   
    for (final packet in packets) {
      final double speed = (packet["speed"] ?? 0).toDouble();

      final double temperature = (packet["temp"] ?? 0).toDouble();

      totalSpeed += speed;

      if (speed > maxSpeed) {
        maxSpeed = speed;
      }

      totalTemperature += temperature;

      if (temperature < minTemperature) {
        minTemperature = temperature;
      }

      if (temperature > maxTemperature) {
        maxTemperature = temperature;
      }
    }

    final int packetCount = packets.length;

    final double averageSpeed = packetCount == 0
        ? 0.0
        : totalSpeed / packetCount;

    final double averageTemperature = packetCount == 0
        ? 0.0
        : totalTemperature / packetCount;

    if (packetCount == 0) {
      minTemperature = 0.0;
      maxTemperature = 0.0;
    }

    // ============================================================
    // Dates
    // ============================================================

    final DateTime startTime = DateTime.parse(trip["startTime"].toString());

    DateTime? endTime;

    if (trip["endTime"] != null) {
      endTime = DateTime.parse(trip["endTime"].toString());
    }

    // ============================================================
    // Build Report
    // ============================================================

    return TripReportModel(
      tripId: (trip["tripId"] ?? tripId).toString(),

      // Company
      companyId: companyId,

      companyName: companyName,

      // Driver
      driverId: (trip["driverId"] ?? "").toString(),

      driverName: (trip["driverName"] ?? "").toString(),

      // Truck
      truckId: (trip["truckId"] ?? "").toString(),

      // Dates
      startTime: startTime,

      endTime: endTime,

      // Status
      status: (trip["status"] ?? "").toString(),

      // Statistics
      packetCount: packetCount,

      // Firestore speed is m/s.
      // Convert to km/h.
      averageSpeed: averageSpeed * 3.6,

      maxSpeed: maxSpeed * 3.6,

      averageTemperature: averageTemperature,

      minTemperature: minTemperature,

      maxTemperature: maxTemperature,

      // GPS
      //
      // IMPORTANT:
      // There is now ONE source of truth.
      route: route,
    );
  }
}





