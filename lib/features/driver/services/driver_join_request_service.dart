import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coldchain_shield/features/enterprise/models/driver_join_request_model.dart';
import 'package:flutter/material.dart';

class DriverJoinRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection("driver_join_requests");

  // ============================================================
  // Send Join Request
  // ============================================================

  Future<String> sendRequest({
    required String driverId,
    required String driverName,
    required String companyId,
  }) async {
    final requestDoc = _requests.doc();

    final request = DriverJoinRequestModel(
      requestId: requestDoc.id,
      driverId: driverId,
      driverName: driverName,
      companyId: companyId,
      status: "pending",
      createdAt: DateTime.now(),
    );

    await requestDoc.set(request.toMap());

    debugPrint("🟢 Join Request Created: ${requestDoc.id}");

    return requestDoc.id;
  }

  // ============================================================
  // Get Company Requests
  // ============================================================

  Future<List<DriverJoinRequestModel>> getCompanyRequests(
    String companyId,
  ) async {
    final snapshot = await _requests
        .where("companyId", isEqualTo: companyId)
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => DriverJoinRequestModel.fromMap(doc.data()))
        .toList();
  }

  // ============================================================
  // Stream Company Requests
  // ============================================================

  Stream<List<DriverJoinRequestModel>> companyRequestsStream(String companyId) {
    return _requests
        .where("companyId", isEqualTo: companyId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DriverJoinRequestModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // ============================================================
  // Get Driver Requests
  // ============================================================

  Future<List<DriverJoinRequestModel>> getDriverRequests(
    String driverId,
  ) async {
    final snapshot = await _requests
        .where("driverId", isEqualTo: driverId)
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => DriverJoinRequestModel.fromMap(doc.data()))
        .toList();
  }

  // // ============================================================
  // // Reject Request
  // // ============================================================

  Future<void> rejectRequest(String requestId) async {
    await _requests.doc(requestId).update({
      "status": "rejected",
      "respondedAt": DateTime.now().toIso8601String(),
    });

    debugPrint("🔴 Join Request Rejected: $requestId");
  }

  Future<void> acceptRequest({
    required String requestId,
    required String truckId,
  }) async {
    final requestDoc = _requests.doc(requestId);

    debugPrint("🟡 ACCEPT START");
    debugPrint("🟡 Request ID: $requestId");
    debugPrint("🟡 Truck ID: $truckId");

    final requestSnapshot = await requestDoc.get();

    if (!requestSnapshot.exists || requestSnapshot.data() == null) {
      throw Exception("Join request not found");
    }

    final request = DriverJoinRequestModel.fromMap(requestSnapshot.data()!);

    debugPrint("🟡 Driver ID: ${request.driverId}");
    debugPrint("🟡 Company ID: ${request.companyId}");
    debugPrint("🟡 Request status: ${request.status}");

    if (!request.isPending) {
      throw Exception("This request has already been processed");
    }

    final cleanTruckId = truckId.trim();

    if (cleanTruckId.isEmpty) {
      throw Exception("Truck ID cannot be empty");
    }

    final driverDoc = _firestore.collection("users").doc(request.driverId);

    final batch = _firestore.batch();

    // ============================================================
    // 1. ربط السائق بالشركة والشاحنة
    // ============================================================

    batch.set(driverDoc, {
      "companyId": request.companyId,
      "truckId": cleanTruckId,
    }, SetOptions(merge: true));

    // ============================================================
    // 2. تحديث طلب الانضمام
    // ============================================================

    batch.update(requestDoc, {
      "status": "accepted",
      "truckId": cleanTruckId,
      "respondedAt": DateTime.now().toIso8601String(),
    });

    debugPrint("🟡 Sending Firestore batch...");

    await batch.commit();

    debugPrint(
      "🟢 Driver ${request.driverId} joined company "
      "${request.companyId} with truck $cleanTruckId",
    );
  }

  // ============================================================
  // Get Single Request
  // ============================================================

  Future<DriverJoinRequestModel?> getRequest(String requestId) async {
    final doc = await _requests.doc(requestId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return DriverJoinRequestModel.fromMap(doc.data()!);
  }

  // ============================================================
  // Delete Request
  // ============================================================

  Future<void> deleteRequest(String requestId) async {
    await _requests.doc(requestId).delete();

    debugPrint("🗑 Join Request Deleted: $requestId");
  }
}
