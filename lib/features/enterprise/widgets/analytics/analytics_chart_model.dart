import 'analytics_chart_point.dart';

class AnalyticsChartModel {
  final List<AnalyticsChartPoint> temperature;

  final List<AnalyticsChartPoint> speed;

  final List<AnalyticsChartPoint> distance;

  const AnalyticsChartModel({
    required this.temperature,
    required this.speed,
    required this.distance,
  });

  factory AnalyticsChartModel.empty() {
    return const AnalyticsChartModel(
      temperature: [],
      speed: [],
      distance: [],
    );
  }
}