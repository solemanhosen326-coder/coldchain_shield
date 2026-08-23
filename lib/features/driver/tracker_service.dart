import 'dart:async';

import 'package:coldchain_shield/features/driver/cache_box.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum TrackingStartResult {
  success,
  gpsDisabled,
  permissionDenied,
  failed,
}

class TrackerService {
  // ============================================================
  // Dependencies
  // ============================================================

  final CacheBox _cacheBox = CacheBox();

  // ============================================================
  // External data
  // ============================================================

  Map<String, dynamic>? driverData;

  String? tripId;

  // ============================================================
  // Stream
  // ============================================================

  StreamSubscription<Position>? _locationSubscription;

  // ============================================================
  // Callbacks
  // ============================================================

  //VoidCallback? onPacketSaved;
  Future<void> Function()? onPacketSaved;
  void Function(Position)? onLocationUpdated;
  void Function(double)? onTemperatureUpdated;

  // ============================================================
  // Tracking configuration
  // ============================================================

  /// Maximum accepted GPS accuracy in meters.
  static const double _maxAccuracyMeters = 40.0;

  /// Minimum real movement required to save a packet.
  static const double _minMovementMeters = 5.0;

  /// Minimum time between saved packets.
  static const Duration _minPacketInterval = Duration(seconds: 5);

  /// Speeds below this value are considered stationary.
  static const double _stationarySpeedKmh = 1.5;

  /// Maximum reasonable truck speed.
  /// This protects against GPS spikes.
  static const double _maxReasonableSpeedKmh = 140.0;

  // ============================================================
  // Current temperature
  // ============================================================

  double _currentTemperature = 4.5;

  void updateTemperature(double temperature) {
    _currentTemperature = temperature;
  }

  // ============================================================
  // Last saved GPS data
  // ============================================================

  Position? _lastSavedPosition;
  DateTime? _lastSavedTime;

  // ============================================================
  // Tracking availability
  // ============================================================

  Future<TrackingStartResult> checkTrackingAvailability() async {
    // ------------------------------------------------------------
    // 1. Check GPS / Location Service
    // ------------------------------------------------------------

    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      debugPrint('❌ GPS service is disabled');

      return TrackingStartResult.gpsDisabled;
    }

    // ------------------------------------------------------------
    // 2. Check location permission
    // ------------------------------------------------------------

    LocationPermission permission =
        await Geolocator.checkPermission();

    // If permission was denied before, request it.
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // ------------------------------------------------------------
    // 3. Permission denied
    // ------------------------------------------------------------

    if (permission == LocationPermission.denied) {
      debugPrint('❌ Location permission denied');

      return TrackingStartResult.permissionDenied;
    }

    // ------------------------------------------------------------
    // 4. Permission permanently denied
    // ------------------------------------------------------------

    if (permission == LocationPermission.deniedForever) {
      debugPrint(
        '❌ Location permission permanently denied',
      );

      return TrackingStartResult.permissionDenied;
    }

    // ------------------------------------------------------------
    // 5. Everything is ready
    // ------------------------------------------------------------

    debugPrint('✅ GPS and location permission ready');

    return TrackingStartResult.success;
  }

  // ============================================================
  // Start tracking
  // ============================================================

  Future<TrackingStartResult> startTracking() async {
    // Prevent starting multiple subscriptions.
    if (_locationSubscription != null) {
      return TrackingStartResult.success;
    }

    // ------------------------------------------------------------
    // Check GPS and permissions BEFORE starting tracking.
    // ------------------------------------------------------------

    final availability =
        await checkTrackingAvailability();

    if (availability != TrackingStartResult.success) {
      return availability;
    }

    // ------------------------------------------------------------
    // Reset previous trip tracking state.
    // ------------------------------------------------------------

    _lastSavedPosition = null;
    _lastSavedTime = null;

    // ------------------------------------------------------------
    // GPS settings
    // ------------------------------------------------------------

    const LocationSettings settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    try {
      _locationSubscription =
          Geolocator.getPositionStream(
        locationSettings: settings,
      ).listen(
        _handleLocation,
        onError: (error) {
          debugPrint(
            '❌ [GPS Tracker] Stream error: $error',
          );
        },
      );

      debugPrint('🛰️ [GPS Tracker] Tracking started');

      return TrackingStartResult.success;
    } catch (e) {
      debugPrint(
        '❌ [GPS Tracker] Failed to start tracking: $e',
      );

      _locationSubscription = null;

      return TrackingStartResult.failed;
    }
  }

  // ============================================================
  // Handle GPS location
  // ============================================================

  Future<void> _handleLocation(Position position) async {
    debugPrint(
      '🛰️ GPS -> '
      '${position.latitude}, '
      '${position.longitude} | '
      'speed=${position.speed} m/s | '
      'accuracy=${position.accuracy}m',
    );

    // ------------------------------------------------------------
    // 1. GPS accuracy validation
    // ------------------------------------------------------------

    if (position.accuracy <= 0 ||
        position.accuracy > _maxAccuracyMeters) {
      debugPrint(
        '⚠️ GPS ignored: poor accuracy '
        '(${position.accuracy.toStringAsFixed(1)}m)',
      );

      // Still update UI with the latest position.
      // But do NOT save a packet.
      onLocationUpdated?.call(position);

      return;
    }

    final now = DateTime.now();

    // ------------------------------------------------------------
    // 2. First valid GPS point
    // ------------------------------------------------------------

    if (_lastSavedPosition == null ||
        _lastSavedTime == null) {
      await _savePacket(
        position: position,
        time: now,
        speedKmh: _normalizeSpeed(position.speed),
      );

      return;
    }

    // ------------------------------------------------------------
    // 3. Calculate distance from last saved packet
    // ------------------------------------------------------------

    final distanceMeters =
        Geolocator.distanceBetween(
      _lastSavedPosition!.latitude,
      _lastSavedPosition!.longitude,
      position.latitude,
      position.longitude,
    );

    // ------------------------------------------------------------
    // 4. Calculate elapsed time
    // ------------------------------------------------------------

    final elapsedSeconds =
        now.difference(_lastSavedTime!).inMilliseconds /
            1000.0;

    if (elapsedSeconds <= 0) {
      return;
    }

    // ------------------------------------------------------------
    // 5. Calculate speed from distance/time
    // ------------------------------------------------------------

    final calculatedSpeedKmh =
        (distanceMeters / elapsedSeconds) * 3.6;

    // GPS reported speed.
    final gpsSpeedKmh =
        _normalizeSpeed(position.speed);

    // Select the most reliable speed.
    final speedKmh = _selectSpeed(
      gpsSpeedKmh: gpsSpeedKmh,
      calculatedSpeedKmh: calculatedSpeedKmh,
    );

    // ------------------------------------------------------------
    // 6. Ignore insignificant movement
    // ------------------------------------------------------------

    if (distanceMeters < _minMovementMeters) {
      debugPrint(
        '⏸️ GPS ignored: movement too small '
        '(${distanceMeters.toStringAsFixed(2)}m)',
      );

      onLocationUpdated?.call(position);

      return;
    }

    // ------------------------------------------------------------
    // 7. Respect packet interval
    // ------------------------------------------------------------

    if (now.difference(_lastSavedTime!) <
        _minPacketInterval) {
      debugPrint(
        '⏱️ GPS ignored: packet interval too short',
      );

      onLocationUpdated?.call(position);

      return;
    }

    // ------------------------------------------------------------
    // 8. Save actual movement packet
    // ------------------------------------------------------------

    await _savePacket(
      position: position,
      time: now,
      speedKmh: speedKmh,
    );
  }

  // ============================================================
  // Normalize GPS speed
  // ============================================================

  double _normalizeSpeed(double speedMetersPerSecond) {
    if (!speedMetersPerSecond.isFinite ||
        speedMetersPerSecond < 0) {
      return 0;
    }

    final speedKmh =
        speedMetersPerSecond * 3.6;

    // GPS spike protection.
    if (speedKmh > _maxReasonableSpeedKmh) {
      return 0;
    }

    // Remove tiny GPS movement noise.
    if (speedKmh < _stationarySpeedKmh) {
      return 0;
    }

    return speedKmh;
  }

  // ============================================================
  // Select the most reliable speed
  // ============================================================

  double _selectSpeed({
    required double gpsSpeedKmh,
    required double calculatedSpeedKmh,
  }) {
    // Both values are valid and reasonably close.
    if (gpsSpeedKmh > 0 &&
        calculatedSpeedKmh > 0 &&
        (gpsSpeedKmh - calculatedSpeedKmh).abs() < 15) {
      return (gpsSpeedKmh + calculatedSpeedKmh) / 2;
    }

    // GPS speed is unreliable.
    // Use calculated movement speed.
    if (calculatedSpeedKmh > 0 &&
        calculatedSpeedKmh <=
            _maxReasonableSpeedKmh) {
      return calculatedSpeedKmh;
    }

    return gpsSpeedKmh;
  }

  // ============================================================
  // Save packet
  // ============================================================

  Future<void> _savePacket({
    required Position position,
    required DateTime time,
    required double speedKmh,
  }) async {
    final locationData = {
      ...?driverData,

      'tripId': tripId,

      'lat': position.latitude,
      'lng': position.longitude,

      // Fake temperature for now.
      'temp': _currentTemperature,

      // Always store speed as km/h.
      'speed': speedKmh,

      'time': time.toIso8601String(),
    };

    await _cacheBox.addLocationToCache(
      locationData,
    );

    // Update last saved data only after
    // the packet was successfully cached.
    _lastSavedPosition = position;
    _lastSavedTime = time;

    debugPrint(
      '📦 PACKET SAVED -> '
      'speed=${speedKmh.toStringAsFixed(1)} km/h',
    );

    // Packet was actually saved.
    
    //onPacketSaved?.call();
    await onPacketSaved?.call();

    // Update UI with latest location.
    onLocationUpdated?.call(position);

    // Update temperature callback.
    onTemperatureUpdated?.call(
      _currentTemperature,
    );
  }

  // ============================================================
  // Stop tracking
  // ============================================================

  Future<void> stopTracking() async {
    await _locationSubscription?.cancel();

    _locationSubscription = null;

    _lastSavedPosition = null;
    _lastSavedTime = null;

    debugPrint(
      '🛑 [GPS Tracker] Tracking stopped',
    );
  }
}




