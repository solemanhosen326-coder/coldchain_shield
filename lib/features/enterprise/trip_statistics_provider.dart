import 'package:flutter/foundation.dart';

import 'models/trip_packet_model.dart';
import 'models/trip_statistics_model.dart';
import 'services/trip_statistics_service.dart';

class TripStatisticsProvider extends ChangeNotifier {
  final TripStatisticsService _service = TripStatisticsService();

  TripStatisticsModel? _statistics;
  TripStatisticsModel? get statistics => _statistics;

  void updateStatistics(List<TripPacketModel> packets) {
    if (packets.isEmpty) {
      _statistics = TripStatisticsModel.empty();
    } else {
      _statistics = _service.calculateStatistics(packets);
    }

    notifyListeners();
  }

  void clear() {
    _statistics = null;
    notifyListeners();
  }
}