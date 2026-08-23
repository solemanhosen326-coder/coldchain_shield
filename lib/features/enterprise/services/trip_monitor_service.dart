import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/trip_packet_model.dart';

class TripMonitorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription? _historySubscription;

  final List<StreamSubscription> _packetSubscriptions = [];

  void Function(List<TripPacketModel>)? onTripsUpdated;

  // آخر Packet لكل رحلة نشطة
  final Map<String, TripPacketModel> _latestTripsByTripId = {};

  // =========================
  // START MONITORING
  // =========================

  Future<void> startMonitoring(String companyId) async {
    await stopMonitoring();

    if (companyId.trim().isEmpty) {
      return;
    }

    _historySubscription = _firestore
        .collection("trip_history")
        .where("companyId", isEqualTo: companyId)
        .where("status", isEqualTo: "running")
        .snapshots()
        .listen(
          _onHistoryChanged,
          onError: (error, stackTrace) {
            print("❌ Trip History Monitor Error: $error");
          },
        );
  }

  // =========================
  // HISTORY CHANGED
  // =========================

  Future<void> _onHistoryChanged(QuerySnapshot snapshot) async {
    // إلغاء Listeners القديمة
    for (final sub in _packetSubscriptions) {
      await sub.cancel();
    }

    _packetSubscriptions.clear();

    // الرحلات التي ما زالت Running
    final activeTripIds = snapshot.docs.map((doc) => doc.id).toSet();

    // حذف الرحلات التي لم تعد Running
    _latestTripsByTripId.removeWhere(
      (tripId, _) => !activeTripIds.contains(tripId),
    );

    // لا توجد أي رحلة نشطة
    if (activeTripIds.isEmpty) {
      onTripsUpdated?.call([]);
      return;
    }

    // إنشاء Listener لكل رحلة نشطة
    for (final doc in snapshot.docs) {
      final tripId = doc.id;

      final subscription = _firestore
          .collection("trip_history")
          .doc(tripId)
          .collection("packets")
          .orderBy("time")
          .snapshots()
          .listen(
            (packetSnapshot) {
              if (packetSnapshot.docs.isEmpty) {
                return;
              }

              final packet = TripPacketModel.fromMap(
                packetSnapshot.docs.last.data(),
              );

              final livePacket = packet.copyWith(tripId: tripId);

              _latestTripsByTripId[tripId] = livePacket;

              _notifyTrips();
            },
            onError: (error, stackTrace) {
              debugPrint("❌ Packet Stream Error for trip $tripId: $error");
            },
          );

      _packetSubscriptions.add(subscription);
    }

    // إرسال الحالة الحالية
    _notifyTrips();
  }

  // =========================
  // NOTIFY
  // =========================

  void _notifyTrips() {
    onTripsUpdated?.call(_latestTripsByTripId.values.toList());
  }

  // =========================
  // STOP MONITORING
  // =========================

  Future<void> stopMonitoring() async {
    await _historySubscription?.cancel();

    _historySubscription = null;

    for (final sub in _packetSubscriptions) {
      await sub.cancel();
    }

    _packetSubscriptions.clear();

    _latestTripsByTripId.clear();
  }
}


