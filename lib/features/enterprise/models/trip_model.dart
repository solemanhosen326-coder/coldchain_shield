class TripModel {
  final double latitude;
  final double longitude;
  final double speed;
  final double temperature;
  final DateTime time;

  TripModel({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.temperature,
    required this.time,
  });

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      latitude: (map["lat"] ?? 0).toDouble(),
      longitude: (map["lng"] ?? 0).toDouble(),
      speed: (map["speed"] ?? 0).toDouble(),
      temperature: (map["temp"] ?? 0).toDouble(),
      time: DateTime.parse(map["time"]),
    );
  }
}