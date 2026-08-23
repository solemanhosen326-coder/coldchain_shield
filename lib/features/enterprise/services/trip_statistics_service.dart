import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import '../models/trip_packet_model.dart';
import '../models/trip_statistics_model.dart';

class TripStatisticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<TripStatisticsModel> getStatistics(String tripId) async {
    final snapshot = await _firestore
        .collection("trip_history")
        .doc(tripId)
        .collection("packets")
        .orderBy("time")
        .get();

    if (snapshot.docs.isEmpty) {
      return TripStatisticsModel.empty();
    }

    final packets = snapshot.docs
        .map((e) => TripPacketModel.fromMap(e.data()))
        .toList();

    return TripStatisticsModel(
      packetsCount: packets.length,
      distanceKm: _calculateDistance(packets),
      averageSpeed: _calculateAverageSpeed(packets),
      averageTemperature: _calculateAverageTemperature(packets),
      maxTemperature: _calculateMaxTemperature(packets),
      minTemperature: _calculateMinTemperature(packets),
      duration: packets.last.time.difference(packets.first.time),
    );
  }

  double _calculateAverageTemperature(List packets) {
    double total = 0;

    for (final p in packets) {
      total += p.temperature;
    }

    return total / packets.length;
  }

  double _calculateAverageSpeed(List<TripPacketModel> packets) {
    double total = 0;

    for (final p in packets) {
      total += p.speed;
    }

    return total / packets.length;
  }

  double _calculateMaxTemperature(List<TripPacketModel> packets) {
    double value = packets.first.temperature;

    for (final p in packets) {
      if (p.temperature > value) {
        value = p.temperature;
      }
    }

    return value;
  }

  double _calculateMinTemperature(List<TripPacketModel> packets) {
    double value = packets.first.temperature;

    for (final p in packets) {
      if (p.temperature < value) {
        value = p.temperature;
      }
    }

    return value;
  }

  double _calculateDistance(List<TripPacketModel> packets) {
    const Distance distance = Distance();

    double km = 0;

    for (int i = 1; i < packets.length; i++) {
      km +=
          distance(
            LatLng(packets[i - 1].latitude, packets[i - 1].longitude),
            LatLng(packets[i].latitude, packets[i].longitude),
          ) /
          1000;
    }

    return km;
  }

  TripStatisticsModel calculateStatistics(List<TripPacketModel> packets) {
    if (packets.isEmpty) {
      return TripStatisticsModel.empty();
    }

    return TripStatisticsModel(
      packetsCount: packets.length,
      distanceKm: _calculateDistance(packets),
      averageSpeed: _calculateAverageSpeed(packets),
      averageTemperature: _calculateAverageTemperature(packets),
      maxTemperature: _calculateMaxTemperature(packets),
      minTemperature: _calculateMinTemperature(packets),
      duration: packets.last.time.difference(packets.first.time),
    );
  }
}
