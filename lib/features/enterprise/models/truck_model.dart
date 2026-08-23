class TruckModel {
  final String truckId;

  final String truckName;

  final String plateNumber;

  final bool isActive;

  final String? assignedDriverId;

  const TruckModel({
    required this.truckId,
    required this.truckName,
    required this.plateNumber,
    required this.isActive,
    required this.assignedDriverId,
  });

  factory TruckModel.fromMap(Map<String, dynamic> map) {
    return TruckModel(
      truckId: map["truckId"] ?? "",

      truckName: map["truckName"] ?? "",

      plateNumber: map["plateNumber"] ?? "",

      isActive: map["isActive"] ?? true,

      assignedDriverId: map["assignedDriverId"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "truckId": truckId,
      "truckName": truckName,
      "plateNumber": plateNumber,
      "isActive": isActive,
      "assignedDriverId": assignedDriverId,
    };
  }
}