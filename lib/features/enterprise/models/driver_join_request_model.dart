class DriverJoinRequestModel {
  final String requestId;

  final String companyId;

  final String driverId;
  final String driverName;

  final String status;

  final DateTime createdAt;

  const DriverJoinRequestModel({
    required this.requestId,
    required this.companyId,
    required this.driverId,
    required this.driverName,
    required this.status,
    required this.createdAt,
  });

  factory DriverJoinRequestModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return DriverJoinRequestModel(
      requestId: map["requestId"] ?? "",
      companyId: map["companyId"] ?? "",
      driverId: map["driverId"] ?? "",
      driverName: map["driverName"] ?? "",
      status: map["status"] ?? "pending",
      createdAt: map["createdAt"] is DateTime
          ? map["createdAt"]
          : DateTime.parse(
              map["createdAt"],
            ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "requestId": requestId,
      "companyId": companyId,
      "driverId": driverId,
      "driverName": driverName,
      "status": status,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  bool get isPending => status == "pending";

  bool get isAccepted => status == "accepted";

  bool get isRejected => status == "rejected";
}