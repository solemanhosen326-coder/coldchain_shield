import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:coldchain_shield/features/driver/models/driver_model.dart';
import 'package:coldchain_shield/features/enterprise/models/enterprise_model.dart';

class DriverService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // Get Driver Data
  // ============================================================

  Future<DriverModel?> getDriverData() async {
    final user = _auth.currentUser;

    if (user == null) {
      print("❌ No Auth User");
      return null;
    }

    final snapshot = await _firestore
        .collection("users")
        .doc(user.uid)
        .get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return DriverModel.fromMap(snapshot.data()!);
  }

  // ============================================================
  // Get Enterprise Data
  // ============================================================

  Future<EnterpriseModel?> getEnterpriseData(
    String companyId,
  ) async {
    if (companyId.isEmpty) {
      return null;
    }

    final snapshot = await _firestore
        .collection("users")
        .doc(companyId)
        .get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return EnterpriseModel.fromMap(snapshot.data()!);
  }
}


