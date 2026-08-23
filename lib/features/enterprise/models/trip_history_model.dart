class TripHistoryModel {
  final String tripId;

  final String companyId;
  final String truckId;

  final String driverId;
  final String driverName;

  final DateTime startTime;
  final DateTime? endTime;

  final String status;

  const TripHistoryModel({
    required this.tripId,
    required this.companyId,
    required this.truckId,
    required this.driverId,
    required this.driverName,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory TripHistoryModel.fromMap(Map<String, dynamic> map) {
    return TripHistoryModel(
      tripId: map["tripId"] ?? "",

      companyId: map["companyId"] ?? "",
      truckId: map["truckId"] ?? "",

      driverId: map["driverId"] ?? "",
      driverName: map["driverName"] ?? "",

      startTime: DateTime.parse(map["startTime"]),

      endTime: map["endTime"] != null
          ? DateTime.parse(map["endTime"])
          : null,

      status: map["status"] ?? "completed",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "tripId": tripId,

      "companyId": companyId,
      "truckId": truckId,

      "driverId": driverId,
      "driverName": driverName,

      "startTime": startTime.toIso8601String(),

      "endTime": endTime?.toIso8601String(),

      "status": status,
    };
  }

  bool get isRunning => status == "running";

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
}