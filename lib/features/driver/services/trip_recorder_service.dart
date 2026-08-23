import 'package:coldchain_shield/features/driver/services/trip_session_service.dart';
import 'package:coldchain_shield/features/enterprise/models/trip_packet_model.dart';
import 'package:coldchain_shield/features/enterprise/services/trip_history_service.dart';

class TripRecorderService {
  final TripHistoryService _history = TripHistoryService();
  final TripSessionService _session = TripSessionService();

  // ============================================================
  // RECORD PACKET
  // ============================================================

  Future<void> recordPacket(TripPacketModel packet) async {
    final String tripId;

    // ------------------------------------------------------------
    // 1. Use existing active trip
    // ------------------------------------------------------------

    if (_session.hasActiveTrip) {
      tripId = _session.currentTripId!;
    }

    // ------------------------------------------------------------
    // 2. Create a new trip if no active trip exists
    // ------------------------------------------------------------

    else {
      tripId = await _history.createTrip(
        firstPacket: packet,
      );

      await _session.startTrip(tripId);
    }

    // ------------------------------------------------------------
    // 3. Attach the current tripId to the packet
    // ------------------------------------------------------------

    final packetWithTrip = packet.copyWith(
      tripId: tripId,
    );

    // ------------------------------------------------------------
    // 4. Save packet inside the current trip
    // ------------------------------------------------------------

    await _history.addPacket(
      tripId: tripId,
      packet: packetWithTrip,
    );
  }

  // ============================================================
  // END CURRENT TRIP
  // ============================================================

  Future<void> endCurrentTrip() async {
    if (!_session.hasActiveTrip) {
      return;
    }

    final tripId = _session.currentTripId!;

    // Finish trip in Firestore.
    await _history.endTrip(tripId);

    // Clear local session.
    await _session.endTrip();
  }
}


