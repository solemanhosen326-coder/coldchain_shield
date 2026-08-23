import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trip_packet_model.dart';

class TripPacketsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TripPacketModel>> packetsStream(String tripId) {
    return _firestore
        .collection("trip_history")
        .doc(tripId)
        .collection("packets")
        .orderBy("time")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((e) => TripPacketModel.fromMap(e.data()))
              .toList(),
        );
  }
}