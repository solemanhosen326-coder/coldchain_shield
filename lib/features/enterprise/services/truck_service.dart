import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/truck_model.dart';

class TruckService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot>? _subscription;

  void Function(List<TruckModel>)? onTrucksUpdated;

  CollectionReference<Map<String, dynamic>> _truckCollection(
    String companyId,
  ) {
    return _firestore
        .collection("companies")
        .doc(companyId)
        .collection("trucks");
  }

  Future<void> startListening(String companyId) async {
    await stopListening();

    _subscription = _truckCollection(companyId)
        .snapshots()
        .listen(
          (snapshot) {
            final trucks = snapshot.docs
                .map((e) => TruckModel.fromMap(e.data()))
                .toList();

            onTrucksUpdated?.call(trucks);
          },
          onError: (error) {
            print("Truck Monitor Error: $error");
          },
        );
  }

  Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> addTruck({
    required String companyId,
    required TruckModel truck,
  }) async {
    await _truckCollection(companyId)
        .doc(truck.truckId)
        .set(truck.toMap());
  }

  Future<void> updateTruck({
    required String companyId,
    required TruckModel truck,
  }) async {
    await _truckCollection(companyId)
        .doc(truck.truckId)
        .update(truck.toMap());
  }

  Future<void> deleteTruck({
    required String companyId,
    required String truckId,
  }) async {
    await _truckCollection(companyId)
        .doc(truckId)
        .delete();
  }

  Future<void> assignDriver({
    required String companyId,
    required String truckId,
    required String driverId,
  }) async {
    await _truckCollection(companyId)
        .doc(truckId)
        .update({
          "assignedDriverId": driverId,
        });
  }
}