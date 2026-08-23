import 'package:flutter/foundation.dart';

import 'models/enterprise_model.dart';
import 'services/enterprise_service.dart';
import 'models/trip_packet_model.dart';
import 'services/trip_monitor_service.dart';

class EnterpriseProvider extends ChangeNotifier {
  final EnterpriseService _enterpriseService = EnterpriseService();
  final TripMonitorService _tripMonitorService = TripMonitorService();
  List<TripPacketModel> get latestTripsPerTruck {
    final Map<String, TripPacketModel> trucks = {};

    for (final trip in _trips) {
      trucks.putIfAbsent(trip.truckId, () => trip);
    }

    return trucks.values.toList();
  }

  List<TripPacketModel> _trips = [];
  List<TripPacketModel> get trips => _trips;

  EnterpriseModel? _enterprise;
  EnterpriseModel? get enterprise => _enterprise;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isMonitoring = false;

  Future<void> startMonitoring() async {
    if (_enterprise == null) return;

    if (_isMonitoring) return;

    _isMonitoring = true;

    _tripMonitorService.onTripsUpdated = (trips) {
      _trips = trips;
      //_route = trips.map((e) => LatLng(e.latitude, e.longitude)).toList();

      notifyListeners();
    };

    //// await _tripMonitorService.startMonitoring(_enterprise!.uid);
    await _tripMonitorService.startMonitoring(_enterprise!.companyId);
  }

  Future<void> stopMonitoring() async {
    await _tripMonitorService.stopMonitoring();

    _isMonitoring = false;

    _trips.clear();

    notifyListeners();
  }

  Future<void> loadEnterpriseData() async {
    _isLoading = true;
    notifyListeners();

    _enterprise = await _enterpriseService.getEnterpriseData();

    _isLoading = false;

    if (_enterprise != null) {
      await startMonitoring();
    }

    notifyListeners();
  }

  Future<void> clearEnterprise() async {
    await stopMonitoring();

    _enterprise = null;
    _isLoading = false;

    notifyListeners();
  }

  int get packetsCount => _trips.length;
  int get trucksCount => _trips.map((e) => e.truckId).toSet().length;
  int get driversCount => _trips.map((e) => e.uid).toSet().length;
  int get overheatingCount => _trips.where((e) => e.temperature > 8).length;
  TripPacketModel? get latestPacket => _trips.isEmpty ? null : _trips.first;
  bool get hasActiveTrips => _trips.isNotEmpty;
  String get companyId => _enterprise?.companyId ?? "";
  bool get isEnterpriseLoaded => _enterprise != null;
}
