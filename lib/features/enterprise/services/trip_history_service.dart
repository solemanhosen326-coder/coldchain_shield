import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coldchain_shield/features/enterprise/models/trip_history_model.dart';
import 'package:flutter/material.dart';
import '../models/trip_packet_model.dart';

class TripHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _history =>
      _firestore.collection("trip_history");

  Future<String> createTrip({required TripPacketModel firstPacket}) async {
    final tripDoc = _history.doc();

    await tripDoc.set({
      "tripId": tripDoc.id,
      "companyId": firstPacket.companyId,
      "truckId": firstPacket.truckId,
      "driverId": firstPacket.uid,
      "driverName": firstPacket.userName,
      "startTime": firstPacket.time.toIso8601String(),
      "endTime": null,
      "status": "running",
    });
    debugPrint("Trip Created: ${tripDoc.id}");
    return tripDoc.id;
  }

  Future<void> addPacket({
    required String tripId,
    required TripPacketModel packet,
  }) async {
    final packetDoc = _history.doc(tripId).collection("packets").doc();

    await packetDoc.set(packet.toMap());
  }

  Future<void> endTrip(String tripId) async {
    debugPrint("Ending Trip = $tripId");
    final doc = await _history.doc(tripId).get();

    if (!doc.exists) {
      return;
    }

    debugPrint("Exists = ${doc.exists}");
    debugPrint("TripId = $tripId");
    await _history.doc(tripId).update({
      "status": "completed",
      "endTime": DateTime.now().toIso8601String(),
    });
  }

  Future<List<TripHistoryModel>> getTrips(String companyId) async {
    final snapshot = await _history
        .where("companyId", isEqualTo: companyId)
        .orderBy("startTime", descending: true)
        .get();

    return snapshot.docs
        .map((e) => TripHistoryModel.fromMap(e.data()))
        .toList();
  }

  Stream<List<TripHistoryModel>> tripsStream(String companyId) {
    return _history
        .where("companyId", isEqualTo: companyId)
        .orderBy("startTime", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((e) => TripHistoryModel.fromMap(e.data()))
              .toList(),
        );
  }

  Future<String> createTripFromDriver({
    required String companyId,
    required String truckId,
    required String driverId,
    required String driverName,
  }) async {
    final tripDoc = _history.doc();

    await tripDoc.set({
      "tripId": tripDoc.id,
      "companyId": companyId,
      "truckId": truckId,
      "driverId": driverId,
      "driverName": driverName,
      "startTime": DateTime.now().toIso8601String(),
      "endTime": null,
      "status": "running",
    });

    debugPrint("Trip Created: ${tripDoc.id}");

    return tripDoc.id;
  }
}
