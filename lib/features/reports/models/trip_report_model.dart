import 'package:latlong2/latlong.dart';

class TripReportModel {
  final String tripId;

  final String companyId;
  final String companyName;

  final String driverId;
  final String driverName;
  final String truckId;

  final DateTime startTime;
  final DateTime? endTime;

  final String status;

  final int packetCount;

  final double averageSpeed;
  final double maxSpeed;

  final double averageTemperature;
  final double minTemperature;
  final double maxTemperature;

  // ============================================================
  // GPS Route
  // ============================================================

  final List<LatLng> route;

  const TripReportModel({
    required this.tripId,

    required this.companyId,
    required this.companyName,

    required this.driverId,
    required this.driverName,
    required this.truckId,

    required this.startTime,
    required this.endTime,

    required this.status,

    required this.packetCount,

    required this.averageSpeed,
    required this.maxSpeed,

    required this.averageTemperature,
    required this.minTemperature,
    required this.maxTemperature,

    required this.route,
  });

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
}


