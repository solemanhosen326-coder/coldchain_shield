import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentTripService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<String?> getRunningTripId(String truckId) {
    return _firestore
        .collection("trip_history")
        .where("truckId", isEqualTo: truckId)
        .where("status", isEqualTo: "running")
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return null;
          }

          return snapshot.docs.first.id;
        });
  }
}