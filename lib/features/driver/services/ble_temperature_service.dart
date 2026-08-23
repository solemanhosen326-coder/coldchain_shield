import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'temperature_service.dart';

class BleTemperatureService implements TemperatureService {
  BleTemperatureService({
    this.deviceName = '',
  });

  /// Optional BLE advertising name filter.
  ///
  /// Empty means the sensor is identified by Minew BeaconPlus
  /// service data instead of its advertising name.
  final String deviceName;

  @override
  void Function(double temperature)? onTemperatureChanged;

  StreamSubscription<List<ScanResult>>? _scanSubscription;

  bool _isStarted = false;

  // ============================================================
  // Duplicate temperature protection
  // ============================================================

  static const Duration _duplicateWindow = Duration(seconds: 5);

  double? _lastTemperature;

  DateTime? _lastTemperatureAt;

  String? _lastSensorId;

  // ============================================================
  // Minew BeaconPlus
  // ============================================================

  /// Minew BeaconPlus Service Data UUID.
  ///
  /// S1 uses UUID 0xFFE1 for BeaconPlus advertising data.
  static final Guid minewServiceUuid = Guid(
    '0000FFE1-0000-1000-8000-00805F9B34FB',
  );

  // ============================================================
  // START
  // ============================================================

  @override
  Future<void> start() async {
    if (_isStarted) {
      debugPrint(
        '🟡 BLE S1 Temperature Service already started.',
      );
      return;
    }

    _isStarted = true;

    try {
      debugPrint(
        '🟢 Minew S1 Temperature Service Started.',
      );

      await _checkBluetooth();

      // ----------------------------------------------------------
      // Listen to live scan results
      // ----------------------------------------------------------

      _scanSubscription = FlutterBluePlus.onScanResults.listen(
        _handleScanResults,
        onError: (error, stackTrace) {
          debugPrint(
            '❌ BLE Scan Error: $error',
          );

          debugPrintStack(
            stackTrace: stackTrace,
          );
        },
      );

      // ----------------------------------------------------------
      // Continuous BLE scanning
      // ----------------------------------------------------------

      await FlutterBluePlus.startScan(
        withServiceData: [
          ServiceDataFilter(minewServiceUuid),
        ],
        continuousUpdates: true,
        continuousDivisor: 1,
        androidScanMode: AndroidScanMode.lowLatency,
      );

      debugPrint(
        '🟢 Minew S1 BLE scanning is active.',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ Minew S1 Temperature Service Error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      await stop();

      rethrow;
    }
  }

  // ============================================================
  // BLUETOOTH CHECK
  // ============================================================

  Future<void> _checkBluetooth() async {
    final supported = await FlutterBluePlus.isSupported;

    if (!supported) {
      throw Exception(
        'Bluetooth Low Energy is not supported '
        'on this device.',
      );
    }

    await FlutterBluePlus.adapterState
        .where(
          (state) =>
              state == BluetoothAdapterState.on,
        )
        .first;

    debugPrint(
      '🟢 Bluetooth is available and enabled.',
    );
  }

  // ============================================================
  // SCAN RESULTS
  // ============================================================

  void _handleScanResults(
    List<ScanResult> results,
  ) {
    for (final result in results) {
      final advertisement =
          result.advertisementData;

      // ----------------------------------------------------------
      // Optional device name filter
      // ----------------------------------------------------------

      final advertisedName =
          advertisement.advName;

      if (deviceName.isNotEmpty &&
          advertisedName.isNotEmpty &&
          advertisedName != deviceName) {
        continue;
      }

      // ----------------------------------------------------------
      // Minew BeaconPlus Service Data
      // ----------------------------------------------------------

      final serviceData =
          advertisement.serviceData[
            minewServiceUuid
          ];

      if (serviceData == null ||
          serviceData.isEmpty) {
        continue;
      }

      _parseMinewS1Data(
        serviceData,
        result,
      );
    }
  }

  // ============================================================
  // PARSE MINEW S1 DATA
  // ============================================================

  void _parseMinewS1Data(
    List<int> bytes,
    ScanResult result,
  ) {
    try {
      /*
        Minew BeaconPlus HT frame:

        Byte 0:
          0xA1 = frame type

        Byte 1:
          0x01 = Temperature + Humidity

        Byte 2:
          Battery percentage

        Bytes 3-4:
          Temperature
          Signed 8.8 fixed-point

        Bytes 5-6:
          Relative humidity
          Signed 8.8 fixed-point

        Remaining bytes:
          Device-specific frame data
      */

      if (bytes.length != 13) {
        debugPrint(
          '⚠️ Invalid Minew S1 packet length: '
          '${bytes.length}',
        );
        return;
      }

      // ----------------------------------------------------------
      // Frame type
      // ----------------------------------------------------------

      final frameType = bytes[0];

      if (frameType != 0xA1) {
        return;
      }

      // ----------------------------------------------------------
      // Frame version
      // ----------------------------------------------------------

      final versionNumber = bytes[1];

      if (versionNumber != 0x01) {
        return;
      }

      // ----------------------------------------------------------
      // Battery
      // ----------------------------------------------------------

      final batteryPercentage = bytes[2];

      // ----------------------------------------------------------
      // Temperature
      // ----------------------------------------------------------

      final temperatureRaw =
          bytes[3] |
          (bytes[4] << 8);

      final temperature =
          _decodeSigned8_8(
        temperatureRaw,
      );

      if (!temperature.isFinite) {
        debugPrint(
          '⚠️ Invalid temperature value.',
        );
        return;
      }

      // ----------------------------------------------------------
      // Humidity
      // ----------------------------------------------------------

      final humidityRaw =
          bytes[5] |
          (bytes[6] << 8);

      final humidity =
          _decodeSigned8_8(
        humidityRaw,
      );

      if (!humidity.isFinite) {
        debugPrint(
          '⚠️ Invalid humidity value.',
        );
        return;
      }

      // ----------------------------------------------------------
      // Sensor identity
      // ----------------------------------------------------------

      final sensorId =
          result.device.remoteId.toString();

      // ----------------------------------------------------------
      // Duplicate protection
      // ----------------------------------------------------------

      if (!_shouldEmitTemperature(
        temperature,
        sensorId,
      )) {
        return;
      }

      // ----------------------------------------------------------
      // Diagnostics
      // ----------------------------------------------------------

      debugPrint(
        '🟢 Minew S1 detected.',
      );

      debugPrint(
        '🌡 Temperature: '
        '${temperature.toStringAsFixed(2)} °C',
      );

      debugPrint(
        '💧 Humidity: '
        '${humidity.toStringAsFixed(2)} %',
      );

      debugPrint(
        '🔋 Battery: '
        '$batteryPercentage%',
      );

      debugPrint(
        '📡 Sensor ID: '
        '$sensorId',
      );

      debugPrint(
        '📶 RSSI: '
        '${result.rssi}',
      );

      // ----------------------------------------------------------
      // Send real temperature to application
      // ----------------------------------------------------------

      onTemperatureChanged?.call(
        temperature,
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ Minew S1 packet parsing error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  // ============================================================
  // DUPLICATE PROTECTION
  // ============================================================

  bool _shouldEmitTemperature(
    double temperature,
    String sensorId,
  ) {
    final now = DateTime.now();

    // First reading.
    if (_lastTemperature == null ||
        _lastTemperatureAt == null ||
        _lastSensorId == null) {
      _lastTemperature = temperature;
      _lastTemperatureAt = now;
      _lastSensorId = sensorId;

      return true;
    }

    // Different sensor.
    if (_lastSensorId != sensorId) {
      _lastTemperature = temperature;
      _lastTemperatureAt = now;
      _lastSensorId = sensorId;

      return true;
    }

    final elapsed =
        now.difference(_lastTemperatureAt!);

    // Temperature changed.
    if (temperature != _lastTemperature) {
      _lastTemperature = temperature;
      _lastTemperatureAt = now;

      return true;
    }

    // Same temperature, but enough time passed.
    if (elapsed >= _duplicateWindow) {
      _lastTemperatureAt = now;

      return true;
    }

    // Duplicate advertisement.
    return false;
  }

  // ============================================================
  // SIGNED 8.8 FIXED POINT
  // ============================================================

  double _decodeSigned8_8(
    int value,
  ) {
    if ((value & 0x8000) != 0) {
      value -= 0x10000;
    }

    return value / 256.0;
  }

  // ============================================================
  // STOP
  // ============================================================

  @override
  Future<void> stop() async {
    try {
      debugPrint(
        '🔴 Stopping Minew S1 Temperature Service...',
      );

      await FlutterBluePlus.stopScan();

      await _scanSubscription?.cancel();

      _scanSubscription = null;

      // Reset duplicate protection.
      _lastTemperature = null;
      _lastTemperatureAt = null;
      _lastSensorId = null;

      _isStarted = false;

      debugPrint(
        '🔴 Minew S1 Temperature Service Stopped.',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ Minew S1 stop error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _isStarted = false;
    }
  }
}




