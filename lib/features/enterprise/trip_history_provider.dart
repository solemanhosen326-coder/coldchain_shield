import 'package:flutter/foundation.dart';

import 'models/trip_history_model.dart';
import 'services/trip_history_service.dart';

class TripHistoryProvider extends ChangeNotifier {
  final TripHistoryService _historyService = TripHistoryService();

  List<TripHistoryModel> _trips = [];
  List<TripHistoryModel> get trips => _trips;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isListening = false;

  Future<void> startListening(String companyId) async {
    if (_isListening) return;

    _isListening = true;

    _isLoading = true;
    notifyListeners();

    _historyService.tripsStream(companyId).listen((history) {
      _trips = history;

      _isLoading = false;

      notifyListeners();
    });
  }

  void stopListening() {
    _isListening = false;
  }

  void clear() {
    _trips.clear();

    _isListening = false;

    notifyListeners();
  }

  int get totalTrips => _trips.length;

  int get completedTrips =>
      _trips.where((e) => e.status == "completed").length;

  int get runningTrips =>
      _trips.where((e) => e.status == "running").length;
}

