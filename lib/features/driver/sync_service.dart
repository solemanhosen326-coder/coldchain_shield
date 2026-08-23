import 'package:coldchain_shield/features/driver/cache_box.dart';
import 'package:coldchain_shield/features/enterprise/models/trip_packet_model.dart';
import 'package:coldchain_shield/features/driver/services/trip_recorder_service.dart';
import 'package:flutter/material.dart';

class SyncService {
  final CacheBox _cacheBox = CacheBox();
  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TripRecorderService _tripRecorder = TripRecorderService();

  void Function(String)? onSyncStatusChanged;

  bool _isSyncing = false;

  Future<void> syncDataToCloud() async {
    // منع تشغيل أكثر من عملية مزامنة في نفس الوقت.
    if (_isSyncing) {
      return;
    }

    _isSyncing = true;

    try {
      final List<Map<String, dynamic>> cachedData =
          _cacheBox.getCachedLocations();

      if (cachedData.isEmpty) {
        return;
      }

      onSyncStatusChanged?.call("SYNCING");

      debugPrint("🌐 Starting sync...");
      debugPrint("📦 Cached packets: ${cachedData.length}");

      for (final data in cachedData) {
        final map = Map<String, dynamic>.from(data);

        final packet = TripPacketModel.fromMap(map);

        await _tripRecorder.recordPacket(packet);
      }

      await _cacheBox.clearCache();

      onSyncStatusChanged?.call("SYNCED");

      debugPrint(
        "🟩 Sync completed: "
        "${cachedData.length} packets uploaded.",
      );
    } catch (e) {
      onSyncStatusChanged?.call("FAILED");

      debugPrint("🟥 Sync failed: $e");
    } finally {
      _isSyncing = false;
    }
  }
}


