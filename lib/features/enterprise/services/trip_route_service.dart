import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class TripRouteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// الحد الأقصى التقريبي للنقاط التي نرسلها إلى الخريطة.
  /// في الاختبار يمكننا إبقاؤه 2000.
  static const int _maxRoutePoints = 2000;

  /// أقل مسافة بين نقطتين حتى نعتبرهما نقطتين مفيدتين للمسار.
  /// 1 متر مناسب حاليًا للاختبار الذي تقوم به.
  static const double _minDistanceMeters = 1.0;

  Stream<Map<String, dynamic>> getRouteWithStatus(String tripId) {
    if (tripId.trim().isEmpty) {
      return Stream.value({"route": <LatLng>[], "status": "unknown"});
    }

    final tripRef = _firestore.collection("trip_history").doc(tripId);

    return Stream.multi((controller) {
      String status = "unknown";
      List<LatLng> route = [];

      StreamSubscription? tripSubscription;
      StreamSubscription? packetsSubscription;

      void emitState() {
        controller.add({"route": _limitRoutePoints(route), "status": status});
      }

      // ==========================================================
      // 1. الاستماع إلى وثيقة الرحلة
      // ==========================================================

      tripSubscription = tripRef.snapshots().listen(
        (tripSnapshot) {
          if (!tripSnapshot.exists) {
            status = "unknown";
            route = [];
            emitState();
            return;
          }

          final data = tripSnapshot.data();

          status = data?["status"]?.toString() ?? "unknown";

          emitState();
        },
        onError: (error) {
          debugPrint("❌ Trip Stream Error: $error");
          controller.addError(error);
        },
      );

      // ==========================================================
      // 2. الاستماع إلى جميع packets
      // ==========================================================

      packetsSubscription = tripRef
          .collection("packets")
          .orderBy("time")
          .snapshots()
          .listen(
            (packetSnapshot) {
              final newRoute = <LatLng>[];

              for (final doc in packetSnapshot.docs) {
                final data = doc.data();

                final latValue = data["lat"];
                final lngValue = data["lng"];

                // حماية من البيانات الناقصة
                if (latValue is! num || lngValue is! num) {
                  continue;
                }

                final point = LatLng(latValue.toDouble(), lngValue.toDouble());

                // أول نقطة
                if (newRoute.isEmpty) {
                  newRoute.add(point);
                  continue;
                }

                // حساب المسافة عن آخر نقطة مفيدة
                final distance = const Distance().as(
                  LengthUnit.Meter,
                  newRoute.last,
                  point,
                );

                // تجاهل النقاط الأقل من 1 متر
                if (distance < _minDistanceMeters) {
                  continue;
                }

                newRoute.add(point);
              }

              route = newRoute;

              emitState();
            },
            onError: (error) {
              debugPrint("❌ Packets Stream Error: $error");
              controller.addError(error);
            },
          );

      // ==========================================================
      // 3. تنظيف الاشتراكات
      // ==========================================================

      controller.onCancel = () async {
        await tripSubscription?.cancel();
        await packetsSubscription?.cancel();
      };
    });
  }

  /// الحصول على المسار مرة واحدة.
  Future<List<LatLng>> getRouteOnce(String tripId) async {
    if (tripId.trim().isEmpty) {
      return [];
    }

    final snapshot = await _firestore
        .collection("trip_history")
        .doc(tripId)
        .collection("packets")
        .orderBy("time")
        .get();

    final route = <LatLng>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final latValue = data["lat"];
      final lngValue = data["lng"];

      if (latValue is! num || lngValue is! num) {
        continue;
      }

      final point = LatLng(latValue.toDouble(), lngValue.toDouble());

      if (route.isEmpty) {
        route.add(point);
        continue;
      }

      final distance = const Distance().as(LengthUnit.Meter, route.last, point);

      if (distance < _minDistanceMeters) {
        continue;
      }

      route.add(point);
    }

    return _limitRoutePoints(route);
  }

  /// يحافظ على البداية والنهاية ويقلل النقاط الوسطية.
  List<LatLng> _limitRoutePoints(List<LatLng> route) {
    if (route.length <= _maxRoutePoints) {
      return route;
    }

    final result = <LatLng>[];

    // البداية
    result.add(route.first);

    final step = (route.length - 2) / (_maxRoutePoints - 2);

    for (int i = 1; i < _maxRoutePoints - 1; i++) {
      final index = (i * step).round();

      if (index > 0 && index < route.length - 1) {
        result.add(route[index]);
      }
    }

    // النهاية
    result.add(route.last);

    return result;
  }
}
