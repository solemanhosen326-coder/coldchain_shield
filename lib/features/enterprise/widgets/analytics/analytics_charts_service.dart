import 'package:coldchain_shield/features/enterprise/services/trip_history_service.dart';
import 'package:coldchain_shield/features/enterprise/services/trip_statistics_service.dart';
import 'package:coldchain_shield/features/enterprise/widgets/analytics/analytics_chart_model.dart';
import 'package:coldchain_shield/features/enterprise/widgets/analytics/analytics_chart_point.dart';

class AnalyticsChartsService {
  final TripHistoryService _historyService = TripHistoryService();
  final TripStatisticsService _statisticsService = TripStatisticsService();

  Future<AnalyticsChartModel> loadCharts(String companyId) async {
    final trips = await _historyService.getTrips(companyId);

    if (trips.isEmpty) {
      return AnalyticsChartModel.empty();
    }

    final temperature = <AnalyticsChartPoint>[];
    final speed = <AnalyticsChartPoint>[];
    final distance = <AnalyticsChartPoint>[];

    final statistics = await Future.wait(
      trips.map((trip) => _statisticsService.getStatistics(trip.tripId)),
    );

    for (int i = 0; i < statistics.length; i++) {
      final stats = statistics[i];

      temperature.add(
        AnalyticsChartPoint(
          x: i.toDouble(),
          y: stats.averageTemperature,
          label: "Trip ${i + 1}",
        ),
      );

      speed.add(
        AnalyticsChartPoint(
          x: i.toDouble(),
          y: stats.averageSpeed,
          label: "Trip ${i + 1}",
        ),
      );

      distance.add(
        AnalyticsChartPoint(
          x: i.toDouble(),
          y: stats.distanceKm,
          label: "Trip ${i + 1}",
        ),
      );
    }

    return AnalyticsChartModel(
      temperature: temperature,
      speed: speed,
      distance: distance,
    );
  }
}
