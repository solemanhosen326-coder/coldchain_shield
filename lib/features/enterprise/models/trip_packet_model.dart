class TripPacketModel {
  final String uid;
  final String userName;
  final String email;
  final String phone;

  final String companyId;
  final String truckId;

  final double latitude;
  final double longitude;
  final double speed;
  final double temperature;

  final DateTime time;
  final String tripId;

  const TripPacketModel({
    required this.uid,
    required this.userName,
    required this.email,
    required this.phone,
    required this.companyId,
    required this.truckId,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.temperature,
    required this.time,
    required this.tripId,
  });

  factory TripPacketModel.fromMap(Map<String, dynamic> map) {
    return TripPacketModel(
      uid: map["uid"] ?? "",
      userName: map["userName"] ?? "",
      email: map["email"] ?? "",
      phone: map["userPhone"] ?? "",
      companyId: map["companyId"] ?? "",
      truckId: map["truckId"] ?? "",
      latitude: (map["lat"] as num).toDouble(),
      longitude: (map["lng"] as num).toDouble(),
      speed: (map["speed"] as num).toDouble(),
      temperature: (map["temp"] as num).toDouble(),
      time: DateTime.parse(map["time"]),
      tripId: map["tripId"] ?? "",
    );
  }
  TripPacketModel copyWith({
    String? uid,
    String? userName,
    String? email,
    String? phone,
    String? companyId,
    String? truckId,
    double? latitude,
    double? longitude,
    double? speed,
    double? temperature,
    DateTime? time,
    String? tripId,
  }) {
    return TripPacketModel(
      uid: uid ?? this.uid,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      companyId: companyId ?? this.companyId,
      truckId: truckId ?? this.truckId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speed: speed ?? this.speed,
      temperature: temperature ?? this.temperature,
      time: time ?? this.time,
      tripId: tripId ?? this.tripId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "userName": userName,
      "email": email,
      "userPhone": phone,
      "companyId": companyId,
      "truckId": truckId,
      "lat": latitude,
      "lng": longitude,
      "speed": speed,
      "temp": temperature,
      "time": time.toIso8601String(),
      "tripId": tripId,
    };
  }
}
