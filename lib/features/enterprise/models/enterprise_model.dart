class EnterpriseModel {
  final String uid;
  final String companyId;
  final String companyName;
  final String email;
  final String phone;
  final String role;

  const EnterpriseModel({
    required this.uid,
    required this.companyId,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory EnterpriseModel.fromMap(Map<String, dynamic> map) {
    return EnterpriseModel(
      uid: map["uid"] ?? "",
      companyId: map["companyId"] ?? "",
      companyName: map["companyName"] ?? map["userName"] ?? "",
      email: map["email"] ?? "",
      phone: map["phone"] ?? map["userPhone"] ?? "",
      role: map["role"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "companyId": companyId,
      "companyName": companyName,
      "email": email,
      "phone": phone,
      "role": role,
    };
  }
}