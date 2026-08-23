class AnalyticsModel {
  final int totalTrips;
  final int runningTrips;
  final int completedTrips;

  final int totalDrivers;
  final int totalTrucks;

  final double averageTemperature;
  final double maxTemperature;
  final double minTemperature;

  final double averageSpeed;

  final double averageDistanceKm;

  final Duration averageTripDuration;
  final int totalPackets;

  const AnalyticsModel({
    required this.totalTrips,
    required this.runningTrips,
    required this.completedTrips,
    required this.totalDrivers,
    required this.totalTrucks,
    required this.averageTemperature,
    required this.maxTemperature,
    required this.minTemperature,
    required this.averageSpeed,
    required this.averageDistanceKm,
    required this.averageTripDuration, required this.totalPackets,
  });

  factory AnalyticsModel.empty() {
    return const AnalyticsModel(
      totalTrips: 0,
      runningTrips: 0,
      completedTrips: 0,
      totalDrivers: 0,
      totalTrucks: 0,
      averageTemperature: 0,
      maxTemperature: 0,
      minTemperature: 0,
      averageSpeed: 0,
      averageDistanceKm: 0,
      averageTripDuration: Duration.zero,
      totalPackets: 0,
    );
  }
}