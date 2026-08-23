import 'dart:async';

import 'package:flutter/foundation.dart';

import 'models/trip_packet_model.dart';
import 'services/trip_packets_service.dart';

class TripPacketsProvider extends ChangeNotifier {
  final TripPacketsService _service = TripPacketsService();

  // =========================
  // PACKETS
  // =========================

  List<TripPacketModel> _packets = [];

  List<TripPacketModel> get packets => _packets;

  // =========================
  // LOADING
  // =========================

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // =========================
  // STREAM
  // =========================

  StreamSubscription<List<TripPacketModel>>? _packetsSubscription;

  bool get isListening => _packetsSubscription != null;

  // =========================
  // CUSTOM LISTENERS
  // =========================

  final List<void Function(List<TripPacketModel>)> _listeners = [];

  void addPacketsListener(void Function(List<TripPacketModel>) listener) {
    _listeners.add(listener);
  }

  void removePacketsListener(void Function(List<TripPacketModel>) listener) {
    _listeners.remove(listener);
  }

  // =========================
  // START LISTENING
  // =========================

  Future<void> startListening(String tripId) async {
    if (tripId.trim().isEmpty) {
      return;
    }

    if (_packetsSubscription != null) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    _packetsSubscription = _service
        .packetsStream(tripId)
        .listen(
          (packets) {
            _packets = packets;

            for (final listener in List.of(_listeners)) {
              listener(_packets);
            }

            _isLoading = false;
            notifyListeners();
          },
          onError: (error, stackTrace) {
            debugPrint('❌ Trip Packets Stream Error: $error');

            _isLoading = false;

            notifyListeners();
          },
        );
  }

  // =========================
  // STOP LISTENING
  // =========================

  Future<void> stopListening() async {
    await _packetsSubscription?.cancel();

    _packetsSubscription = null;

    debugPrint('🛑 Trip Packets Listener Stopped');
  }

  // =========================
  // CLEAR
  // =========================

  Future<void> clear() async {
    await stopListening();

    _packets = [];

    _isLoading = false;

    notifyListeners();
  }

  // =========================
  // MANUAL UPDATE
  // =========================

  void updatePackets(List<TripPacketModel> packets) {
    _packets = packets;
    notifyListeners();
  }

  // =========================
  // CURRENT PACKETS
  // =========================

  List<TripPacketModel> get currentPackets => _packets;

  // =========================
  // DISPOSE
  // =========================

  @override
  void dispose() {
    _packetsSubscription?.cancel();
    _packetsSubscription = null;

    _listeners.clear();

    super.dispose();
  }
}
