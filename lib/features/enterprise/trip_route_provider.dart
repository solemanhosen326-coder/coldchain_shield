import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import 'models/trip_packet_model.dart';

class TripRouteProvider extends ChangeNotifier {
  List<LatLng> _route = [];

  List<LatLng> get route => _route;

  void updateRoute(List<TripPacketModel> packets) {
    _route = packets
        .map(
          (packet) => LatLng(
            packet.latitude,
            packet.longitude,
          ),
        )
        .toList();

    notifyListeners();
  }

  void clear() {
    _route.clear();
    notifyListeners();
  }
}