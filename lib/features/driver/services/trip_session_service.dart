import 'package:coldchain_shield/constants/app_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TripSessionService {
  static const String _tripIdKey = 'current_trip_id';

  final Box _sessionBox = Hive.box(HiveBoxes.session);

  Future<void> startTrip(String tripId) async {
    final id = tripId.trim();

    if (id.isEmpty) {
      throw ArgumentError('tripId cannot be empty');
    }

    await _sessionBox.put(_tripIdKey, id);
  }

  String? get currentTripId {
    final value = _sessionBox.get(_tripIdKey);

    if (value is! String) {
      return null;
    }

    final id = value.trim();

    return id.isEmpty ? null : id;
  }

  bool get hasActiveTrip => currentTripId != null;

  Future<void> endTrip() async {
    await _sessionBox.delete(_tripIdKey);
  }

  Future<void> clearSession() async {
    await _sessionBox.clear();
  }
}


