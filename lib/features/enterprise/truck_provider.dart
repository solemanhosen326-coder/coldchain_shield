import 'package:flutter/foundation.dart';

import 'models/truck_model.dart';
import 'services/truck_service.dart';

class TruckProvider extends ChangeNotifier {
  final TruckService _service = TruckService();

  List<TruckModel> _trucks = [];
  List<TruckModel> get trucks => _trucks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isListening = false;

  Future<void> startListening(String companyId) async {
    if (_isListening) return;

    _isListening = true;

    _isLoading = true;

    notifyListeners();

    _service.onTrucksUpdated = (trucks) {
      _trucks = trucks;

      _isLoading = false;

      notifyListeners();
    };

    await _service.startListening(companyId);
  }

  Future<void> stopListening() async {
    await _service.stopListening();

    _isListening = false;
  }

  Future<void> addTruck({
    required String companyId,
    required TruckModel truck,
  }) async {
    await _service.addTruck(
      companyId: companyId,
      truck: truck,
    );
  }

  Future<void> updateTruck({
    required String companyId,
    required TruckModel truck,
  }) async {
    await _service.updateTruck(
      companyId: companyId,
      truck: truck,
    );
  }

  Future<void> deleteTruck({
    required String companyId,
    required String truckId,
  }) async {
    await _service.deleteTruck(
      companyId: companyId,
      truckId: truckId,
    );
  }

  Future<void> assignDriver({
    required String companyId,
    required String truckId,
    required String driverId,
  }) async {
    await _service.assignDriver(
      companyId: companyId,
      truckId: truckId,
      driverId: driverId,
    );
  }

  void clear() {
    _trucks.clear();

    _isListening = false;

    notifyListeners();
  }
}