import 'package:coldchain_shield/features/driver/services/ble_temperature_service.dart';
import 'package:flutter/foundation.dart';

import 'package:coldchain_shield/features/driver/cache_box.dart';
import 'package:coldchain_shield/features/driver/internet_service.dart';
import 'package:coldchain_shield/features/driver/models/driver_model.dart';
import 'package:coldchain_shield/features/driver/services/driver_service.dart';
import 'package:coldchain_shield/features/driver/services/temperature_service.dart';
import 'package:coldchain_shield/features/driver/services/trip_recorder_service.dart';
import 'package:coldchain_shield/features/driver/services/trip_session_service.dart';
import 'package:coldchain_shield/features/driver/tracker_service.dart';

import 'package:coldchain_shield/features/enterprise/models/enterprise_model.dart';
import 'package:coldchain_shield/features/enterprise/services/trip_history_service.dart';

class TripProvider extends ChangeNotifier {
  // ============================================================
  // Services
  // ============================================================

  final TripSessionService _session = TripSessionService();
  final TripHistoryService _tripHistory = TripHistoryService();

  final TrackerService _trackerService = TrackerService();
  final InternetService _internetService = InternetService();
  final CacheBox _cacheBox = CacheBox();

  /// Currently using simulated temperature data.
  ///final TemperatureService _temperatureService = FakeTemperatureService();

  // Real BLE temperature sensor.
  final TemperatureService _temperatureService = BleTemperatureService();

  final DriverService _driverService = DriverService();
  final TripRecorderService _tripRecorder = TripRecorderService();

  // ============================================================
  // Trip State
  // ============================================================

  bool _isTripActive = false;

  bool get isTripActive => _isTripActive;

  String? _tripError;

  String? get tripError => _tripError;

  // ============================================================
  // Cached Packets
  // ============================================================

  int _cachedPacketsCount = 0;

  int get cachedPacketsCount => _cachedPacketsCount;

  // ============================================================
  // Driver / Enterprise
  // ============================================================

  DriverModel? _driver;

  DriverModel? get driver => _driver;

  EnterpriseModel? _enterprise;

  EnterpriseModel? get enterprise => _enterprise;

  // ============================================================
  // Tracking Data
  // ============================================================

  double _currentSpeed = 0.0;

  double get currentSpeed => _currentSpeed;

  double get currentSpeedKmH => _currentSpeed * 3.6;

  double _latitude = 0.0;

  double get latitude => _latitude;

  double _longitude = 0.0;

  double get longitude => _longitude;

  // ============================================================
  // Temperature
  // ============================================================

  static const double _defaultTemperature = 4.5;

  double _currentTemperature = _defaultTemperature;

  double get currentTemperature => _currentTemperature;

  // ============================================================
  // Connection / Sync
  // ============================================================

  String _connectionStatus = "OFFLINE";

  String get connectionStatus => _connectionStatus;

  String _syncStatus = "IDLE";

  String get syncStatus => _syncStatus;

  // ============================================================
  // START TRIP
  // ============================================================

  Future<void> startTrip() async {
    // Prevent duplicate starts.
    if (_isTripActive) {
      debugPrint("⚠️ Trip is already active.");
      return;
    }

    _clearTripError();
    notifyListeners();

    try {
      // ----------------------------------------------------------
      // 1. Check GPS availability BEFORE creating Firestore trip
      // ----------------------------------------------------------

      final trackingAvailability = await _trackerService
          .checkTrackingAvailability();

      if (trackingAvailability != TrackingStartResult.success) {
        _setTrackingError(trackingAvailability);
        notifyListeners();
        return;
      }

      // ----------------------------------------------------------
      // 2. Load driver data
      // ----------------------------------------------------------

      await loadDriverData();

      if (_driver == null) {
        _tripError = "تعذر تحميل بيانات السائق";
        notifyListeners();
        return;
      }

      // ----------------------------------------------------------
      // 3. Validate required driver information
      // ----------------------------------------------------------

      final companyId = _driver!.companyId.trim();
      final truckId = _driver!.truckId.trim();
      final driverId = _driver!.uid.trim();
      final driverName = _driver!.userName.trim();

      if (companyId.isEmpty) {
        _tripError = "السائق غير مرتبط بشركة";
        notifyListeners();
        return;
      }

      if (truckId.isEmpty) {
        _tripError = "لم يتم تعيين شاحنة لهذا السائق";
        notifyListeners();
        return;
      }

      if (driverId.isEmpty) {
        _tripError = "بيانات السائق غير صالحة";
        notifyListeners();
        return;
      }

      // ----------------------------------------------------------
      // 4. Create trip in Firestore
      // ----------------------------------------------------------

      final tripId = await _tripHistory.createTripFromDriver(
        companyId: companyId,
        truckId: truckId,
        driverId: driverId,
        driverName: driverName,
      );

      debugPrint("🟢 Trip created: $tripId");

      // ----------------------------------------------------------
      // 5. Save current trip locally
      // ----------------------------------------------------------

      await _session.startTrip(tripId);

      debugPrint("🟢 Current session trip: ${_session.currentTripId}");

      // ----------------------------------------------------------
      // 6. Configure Tracker
      // ----------------------------------------------------------

      _trackerService.tripId = tripId;
      _configureTrackerCallbacks();

      // ----------------------------------------------------------
      // 7. Configure Internet callbacks
      // ----------------------------------------------------------

      _configureInternetCallbacks();

      // ----------------------------------------------------------
      // 8. Configure Temperature callbacks
      // ----------------------------------------------------------

      _temperatureService.onTemperatureChanged = updateTemperature;

      // ----------------------------------------------------------
      // 9. Start GPS tracking
      // ----------------------------------------------------------

      await _internetService.startListening();

      final trackingResult = await _trackerService.startTracking();

      if (trackingResult != TrackingStartResult.success) {
        debugPrint("❌ Tracker failed after trip creation: $trackingResult");

        // The trip was already created, so clean it up.
        await _cleanupFailedTrip(tripId);

        _setTrackingError(trackingResult);
        notifyListeners();
        return;
      }

      // ----------------------------------------------------------
      // 10. Start temperature service
      // ----------------------------------------------------------

      await _temperatureService.start();

      // ----------------------------------------------------------
      // 11. Start internet monitoring
      // ----------------------------------------------------------

      // _internetService.startListening();

      // ----------------------------------------------------------
      // 12. Refresh cache count
      // ----------------------------------------------------------

      refreshCachedPacketsCount();

      // ----------------------------------------------------------
      // 13. Trip is now officially active
      // ----------------------------------------------------------

      _isTripActive = true;
      _tripError = null;

      notifyListeners();

      debugPrint("🟢 Trip started successfully: $tripId");
    } catch (e, stackTrace) {
      debugPrint("❌ Failed to start trip: $e");
      debugPrintStack(stackTrace: stackTrace);

      _tripError = "تعذر بدء الرحلة، حاول مرة أخرى";

      notifyListeners();
    }
  }

  // ============================================================
  // STOP TRIP
  // ============================================================

  Future<void> stopTrip() async {
    if (!_isTripActive) {
      debugPrint("⚠️ No active trip to stop.");
      return;
    }

    try {
      // ----------------------------------------------------------
      // 1. Finish current trip recording
      // ----------------------------------------------------------

      await _tripRecorder.endCurrentTrip();

      // ----------------------------------------------------------
      // 2. Stop GPS
      // ----------------------------------------------------------

      await _trackerService.stopTracking();

      // ----------------------------------------------------------
      // 3. Stop internet monitoring
      // ----------------------------------------------------------

      await _internetService.stopListening();

      // ----------------------------------------------------------
      // 4. Stop temperature service
      // ----------------------------------------------------------

      await _temperatureService.stop();
    } catch (e, stackTrace) {
      debugPrint("❌ Error while stopping trip: $e");
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      // ----------------------------------------------------------
      // Always clean callbacks
      // ----------------------------------------------------------

      _clearServiceCallbacks();

      // ----------------------------------------------------------
      // Reset provider state
      // ----------------------------------------------------------

      _resetTripState();

      notifyListeners();
    }

    debugPrint("🛑 Trip stopped.");
  }

  // ============================================================
  // TOGGLE TRIP
  // ============================================================

  Future<void> toggleTrip() async {
    if (_isTripActive) {
      await stopTrip();
    } else {
      await startTrip();
    }
  }

  // ============================================================
  // TRACKER CALLBACKS
  // ============================================================

  void _configureTrackerCallbacks() {
    // _trackerService.onPacketSaved = refreshCachedPacketsCount;
    _trackerService.onPacketSaved = () async {
      refreshCachedPacketsCount();

      if (_internetService.isConnected) {
        await _internetService.syncIfConnected();
      }
    };

    _trackerService.onLocationUpdated = (position) {
      updateTrackingData(
        speed: position.speed,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    };
  }

  // ============================================================
  // INTERNET CALLBACKS
  // ============================================================

  void _configureInternetCallbacks() {
    _internetService.onConnectionChanged = (connected) {
      updateConnectionStatus(connected ? "ONLINE" : "OFFLINE");
    };

    _internetService.onSyncStatusChanged = updateSyncStatus;
  }

  // ============================================================
  // CLEAR SERVICE CALLBACKS
  // ============================================================

  void _clearServiceCallbacks() {
    _trackerService.onPacketSaved = null;
    _trackerService.onLocationUpdated = null;

    _internetService.onConnectionChanged = null;
    _internetService.onSyncStatusChanged = null;

    _temperatureService.onTemperatureChanged = null;
  }

  // ============================================================
  // FAILED TRIP CLEANUP
  // ============================================================

  Future<void> _cleanupFailedTrip(String tripId) async {
    try {
      await _trackerService.stopTracking();
    } catch (e) {
      debugPrint("⚠️ Failed to stop tracker: $e");
    }

    try {
      await _internetService.stopListening();
    } catch (e) {
      debugPrint("⚠️ Failed to stop internet service: $e");
    }

    try {
      await _temperatureService.stop();
    } catch (e) {
      debugPrint("⚠️ Failed to stop temperature service: $e");
    }

    _clearServiceCallbacks();

    try {
      await _tripHistory.endTrip(tripId);
    } catch (e) {
      debugPrint("⚠️ Failed to end Firestore trip: $e");
    }

    try {
      await _session.endTrip();
    } catch (e) {
      debugPrint("⚠️ Failed to end trip session: $e");
    }

    _resetTripState();
  }

  // ============================================================
  // RESET TRIP STATE
  // ============================================================

  void _resetTripState() {
    _isTripActive = false;

    _currentSpeed = 0.0;

    _latitude = 0.0;

    _longitude = 0.0;

    _syncStatus = "IDLE";

    _cachedPacketsCount = 0;

    _currentTemperature = _defaultTemperature;
  }

  // ============================================================
  // TRACKING ERROR
  // ============================================================

  void _setTrackingError(TrackingStartResult result) {
    switch (result) {
      case TrackingStartResult.gpsDisabled:
        _tripError = "يرجى تفعيل الموقع لبدء الرحلة";
        break;

      case TrackingStartResult.permissionDenied:
        _tripError = "يرجى السماح للتطبيق باستخدام الموقع";
        break;

      case TrackingStartResult.failed:
        _tripError = "تعذر تشغيل خدمة التتبع، حاول مرة أخرى";
        break;

      case TrackingStartResult.success:
        _tripError = null;
        break;
    }
  }

  // ============================================================
  // TRIP ERROR
  // ============================================================

  void _clearTripError() {
    _tripError = null;
  }

  // ============================================================
  // CACHE
  // ============================================================

  void refreshCachedPacketsCount() {
    _cachedPacketsCount = _cacheBox.getCachedPacketsCount();

    notifyListeners();
  }

  // ============================================================
  // TEMPERATURE
  // ============================================================

  void updateTemperature(double temperature) {
    if (!temperature.isFinite) {
      return;
    }

    _currentTemperature = temperature;

    _trackerService.updateTemperature(temperature);

    notifyListeners();
  }

  // ============================================================
  // CONNECTION
  // ============================================================

  void updateConnectionStatus(String status) {
    _connectionStatus = status;

    notifyListeners();
  }

  // ============================================================
  // SYNC
  // ============================================================

  void updateSyncStatus(String status) {
    _syncStatus = status;

    if (status == "SYNCED") {
      _cachedPacketsCount = _cacheBox.getCachedPacketsCount();
    }

    notifyListeners();
  }

  // ============================================================
  // TRACKING DATA
  // ============================================================

  void updateTrackingData({
    required double speed,
    required double latitude,
    required double longitude,
  }) {
    _currentSpeed = speed;
    _latitude = latitude;
    _longitude = longitude;

    notifyListeners();
  }

  // ============================================================
  // LOAD DRIVER DATA
  // ============================================================

  Future<void> loadDriverData() async {
    try {
      final driver = await _driverService.getDriverData();

      if (driver == null) {
        _driver = null;
        _enterprise = null;
        _trackerService.driverData = null;

        notifyListeners();
        return;
      }

      _driver = driver;

      // ----------------------------------------------------------
      // Enterprise
      // ----------------------------------------------------------

      if (driver.companyId.trim().isNotEmpty) {
        _enterprise = await _driverService.getEnterpriseData(driver.companyId);
      } else {
        _enterprise = null;
      }

      // ----------------------------------------------------------
      // Tracker driver data
      // ----------------------------------------------------------

      _trackerService.driverData = driver.toMap();

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint("❌ Failed to load driver data: $e");
      debugPrintStack(stackTrace: stackTrace);

      _driver = null;
      _enterprise = null;
      _trackerService.driverData = null;

      notifyListeners();
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _clearServiceCallbacks();

    _trackerService.stopTracking();
    _internetService.stopListening();
    _temperatureService.stop();

    super.dispose();
  }
}





