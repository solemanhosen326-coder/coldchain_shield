class TripStatisticsModel {
  final int packetsCount;

  final double distanceKm;

  final double averageSpeed;

  final double averageTemperature;

  final double maxTemperature;

  final double minTemperature;

  final Duration duration;

  const TripStatisticsModel({
    required this.packetsCount,
    required this.distanceKm,
    required this.averageSpeed,
    required this.averageTemperature,
    required this.maxTemperature,
    required this.minTemperature,
    required this.duration,
  });

  factory TripStatisticsModel.empty() {
    return const TripStatisticsModel(
      packetsCount: 0,
      distanceKm: 0,
      averageSpeed: 0,
      averageTemperature: 0,
      maxTemperature: 0,
      minTemperature: 0,
      duration: Duration.zero,
    );
  }
}


