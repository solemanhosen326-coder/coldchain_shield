import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/enterprise_model.dart';

class EnterpriseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<EnterpriseModel?> getEnterpriseData() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final snapshot = await _firestore
        .collection("users")
        .doc(user.uid)
        .get();

    if (!snapshot.exists) {
      return null;
    }

    return EnterpriseModel.fromMap(snapshot.data()!);
  }
}