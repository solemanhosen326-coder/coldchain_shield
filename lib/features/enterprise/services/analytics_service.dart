import 'package:coldchain_shield/features/enterprise/models/analytics_model.dart';
import 'package:coldchain_shield/features/enterprise/models/trip_history_model.dart';
import 'package:coldchain_shield/features/enterprise/models/trip_statistics_model.dart';

import 'trip_history_service.dart';
import 'trip_statistics_service.dart';

class AnalyticsService {
  final TripHistoryService _historyService = TripHistoryService();
  final TripStatisticsService _statisticsService = TripStatisticsService();

  Future<AnalyticsModel> loadAnalytics(String companyId) async {
    final List<TripHistoryModel> trips = await _historyService.getTrips(
      companyId,
    );

    if (trips.isEmpty) {
      return AnalyticsModel.empty();
    }
    int totalPackets = 0;

    int runningTrips = 0;
    int completedTrips = 0;

    final drivers = <String>{};
    final trucks = <String>{};

    double totalTemperature = 0;
    double maxTemperature = double.negativeInfinity;
    double minTemperature = double.infinity;

    double totalSpeed = 0;
    double totalDistance = 0;

    Duration totalDuration = Duration.zero;

    int statisticsCount = 0;

    for (final trip in trips) {
      drivers.add(trip.driverId);
      trucks.add(trip.truckId);

      if (trip.isRunning) {
        runningTrips++;
      } else {
        completedTrips++;
      }

      final TripStatisticsModel stats = await _statisticsService.getStatistics(
        trip.tripId,
      );

      totalPackets += stats.packetsCount;

      totalTemperature += stats.averageTemperature;

      if (stats.maxTemperature > maxTemperature) {
        maxTemperature = stats.maxTemperature;
      }

      if (stats.minTemperature < minTemperature) {
        minTemperature = stats.minTemperature;
      }

      totalSpeed += stats.averageSpeed;
      totalDistance += stats.distanceKm;
      totalDuration += trip.duration;

      statisticsCount++;
    }

    return AnalyticsModel(
      totalPackets: totalPackets,
      totalTrips: trips.length,
      runningTrips: runningTrips,
      completedTrips: completedTrips,
      totalDrivers: drivers.length,
      totalTrucks: trucks.length,
      averageTemperature: statisticsCount == 0
          ? 0
          : totalTemperature / statisticsCount,
      maxTemperature: statisticsCount == 0 ? 0 : maxTemperature,
      minTemperature: statisticsCount == 0 ? 0 : minTemperature,
      averageSpeed: statisticsCount == 0 ? 0 : totalSpeed / statisticsCount,
      averageDistanceKm: statisticsCount == 0
          ? 0
          : totalDistance / statisticsCount,
      averageTripDuration: Duration(
        milliseconds: statisticsCount == 0
            ? 0
            : totalDuration.inMilliseconds ~/ statisticsCount,
      ),
    );
  }
}
