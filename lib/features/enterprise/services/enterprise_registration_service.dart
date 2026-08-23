import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/enterprise_model.dart';

class EnterpriseRegistrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createCompany({
    required EnterpriseModel company,
  }) async {
    // إنشاء وثيقة الشركة
    await _firestore
        .collection("companies")
        .doc(company.companyId)
        .set(company.toMap());

    // تحديث المستخدم ليصبح مرتبطاً بهذه الشركة
    await _firestore.collection("users").doc(company.uid).update({
      "companyId": company.companyId,
    });
  }
}