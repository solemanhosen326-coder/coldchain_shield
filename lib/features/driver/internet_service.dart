import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coldchain_shield/features/driver/sync_service.dart';
import 'package:flutter/foundation.dart';

class InternetService {
  final Connectivity _connectivity = Connectivity();
  final SyncService _syncService = SyncService();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void Function(bool)? onConnectionChanged;
  void Function(String)? onSyncStatusChanged;

  bool _isConnected = false;

  bool get isConnected => _isConnected;

  // ============================================================
  // START LISTENING
  // ============================================================

  Future<void> startListening() async {
    if (_subscription != null) return;

    // ربط callback قبل بدء أي مزامنة.
    _syncService.onSyncStatusChanged = onSyncStatusChanged;

    // ==========================================================
    // 1. فحص حالة الإنترنت الحالية مباشرة
    // ==========================================================

    final results = await _connectivity.checkConnectivity();

    _isConnected = results.any(
      (result) => result != ConnectivityResult.none,
    );

    onConnectionChanged?.call(_isConnected);

    if (_isConnected) {
      debugPrint("🌐 Internet already connected.");

      // مزامنة أي بيانات موجودة مسبقًا في Cache.
      await syncIfConnected();
    }

    // ==========================================================
    // 2. الاستماع لأي تغيير لاحق
    // ==========================================================

    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) async {
        final connected = results.any(
          (result) => result != ConnectivityResult.none,
        );

        _isConnected = connected;

        onConnectionChanged?.call(connected);

        if (connected) {
          debugPrint(
            "🌐 Internet connection restored.",
          );

          await syncIfConnected();
        }
      },
    );
  }

  // ============================================================
  // SYNC IF CONNECTED
  // ============================================================

  Future<void> syncIfConnected() async {
    if (!_isConnected) {
      return;
    }

    await _syncService.syncDataToCloud();
  }

  // ============================================================
  // STOP LISTENING
  // ============================================================

  Future<void> stopListening() async {
    await _subscription?.cancel();

    _subscription = null;
  }
}



