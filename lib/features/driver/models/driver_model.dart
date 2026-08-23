class DriverModel {
  final String uid;
  final String userName;
  final String email;
  final String phone;
  final String role;
  final String companyId;
  final String truckId;

  const DriverModel({
    required this.uid,
    required this.userName,
    required this.email,
    required this.phone,
    required this.role,
    required this.companyId,
    required this.truckId,
  });

  factory DriverModel.fromMap(Map<String, dynamic> map) {
    return DriverModel(
      uid: map["uid"] ?? "",
      userName: map["userName"] ?? "",

      email: map["email"] ?? "",
      phone: map["userPhone"] ?? "",
      role: map["role"] ?? "",
      companyId: map["companyId"] ?? "",
      truckId: map["truckId"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "userName": userName,
      "email": email,
      "userPhone": phone,
      "role": role,
      "companyId": companyId,
      "truckId": truckId,
    };
  }
}
