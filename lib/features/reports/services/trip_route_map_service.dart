import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:latlong2/latlong.dart';

class TripRouteMapService {
  TripRouteMapService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 20),
              ),
            );

  final Dio _dio;

  // ============================================================
  // Configuration
  // ============================================================

  static const int _tileSize = 256;

  // Auto Zoom range.
  static const int _minZoom = 3;
  static const int _maxZoom = 18;

  // Final image size for PDF.
  static const int _outputWidth = 1000;
  static const int _outputHeight = 650;

  // Geographic padding around route.
  static const double _paddingFactor = 0.15;

  // Minimum padding for very short routes.
  static const double _minimumLatPadding = 0.002;
  static const double _minimumLngPadding = 0.002;

  // ============================================================
  // OpenStreetMap Free Tile Servers
  // ============================================================

  static const List<String> _tileServers = [
    'https://a.tile.openstreetmap.fr/osmfr',
    'https://b.tile.openstreetmap.fr/osmfr',
    'https://c.tile.openstreetmap.fr/osmfr',
  ];

  // ============================================================
  // Main
  // ============================================================

  Future<Uint8List> generateRouteMap({
    required List<LatLng> points,
  }) async {
    if (points.isEmpty) {
      throw Exception('No route points available');
    }

    debugPrint('🗺️ Generating route map...');
    debugPrint('🗺️ Route points = ${points.length}');

    // ----------------------------------------------------------
    // 1. Clean route
    // ----------------------------------------------------------

    final route = _cleanPoints(points);

    if (route.isEmpty) {
      throw Exception(
        'Route contains no valid points',
      );
    }

    debugPrint(
      '🟢 First point = ${route.first}',
    );

    debugPrint(
      '🔴 Last point = ${route.last}',
    );

    // ----------------------------------------------------------
    // 2. Single point
    // ----------------------------------------------------------

    if (route.length == 1) {
      return _generateSinglePointMap(
        route.first,
      );
    }

    // ----------------------------------------------------------
    // 3. Calculate geographic bounds
    // ----------------------------------------------------------

    final bounds = _calculateBounds(route);

    debugPrint(
      '🗺️ Bounds: '
      '${bounds.minLat}, ${bounds.minLng} -> '
      '${bounds.maxLat}, ${bounds.maxLng}',
    );

    // ----------------------------------------------------------
    // 4. Auto Zoom
    // ----------------------------------------------------------

    final zoom = _calculateAutoZoom(
      bounds,
    );

    debugPrint(
      '🔍 Auto Zoom = $zoom',
    );

    // ----------------------------------------------------------
    // 5. Calculate tile range
    // ----------------------------------------------------------

    final tileInfo = _calculateTileRange(
      bounds,
      zoom,
    );

    debugPrint(
      '🗺️ Tiles: '
      '${tileInfo.minX}..${tileInfo.maxX} x '
      '${tileInfo.minY}..${tileInfo.maxY}',
    );

    // ----------------------------------------------------------
    // 6. Download + compose map tiles
    // ----------------------------------------------------------

    final mapImage =
        await _downloadAndComposeTiles(
      tileInfo,
      zoom,
    );

    // ----------------------------------------------------------
    // 7. Project GPS coordinates to image pixels
    // ----------------------------------------------------------

    final projectedPoints = route.map(
      (point) {
        return _projectPoint(
          point,
          tileInfo,
          zoom,
        );
      },
    ).toList();

    debugPrint(
      '📍 Projected points = '
      '${projectedPoints.length}',
    );

    for (int i = 0;
        i < projectedPoints.length;
        i++) {
      debugPrint(
        '📍 Point $i: '
        '${projectedPoints[i].x}, '
        '${projectedPoints[i].y}',
      );
    }

    // ----------------------------------------------------------
    // 8. Draw route
    // ----------------------------------------------------------

    debugPrint(
      '🛣️ Drawing route with '
      '${projectedPoints.length} points',
    );

    _drawRoute(
      mapImage,
      projectedPoints,
    );

    debugPrint(
      '✅ Route drawn successfully',
    );

    // ----------------------------------------------------------
    // 9. Start marker
    // ----------------------------------------------------------

    _drawStartMarker(
      mapImage,
      projectedPoints.first,
    );

    // ----------------------------------------------------------
    // 10. End marker
    // ----------------------------------------------------------

    _drawEndMarker(
      mapImage,
      projectedPoints.last,
    );

    // ----------------------------------------------------------
    // 11. Legend
    // ----------------------------------------------------------

    _drawLegend(
      mapImage,
    );

    // ----------------------------------------------------------
    // 12. Attribution
    // ----------------------------------------------------------

    _drawAttribution(
      mapImage,
    );

    // ----------------------------------------------------------
    // 13. Resize final image
    // ----------------------------------------------------------

    final resized = img.copyResize(
      mapImage,
      width: _outputWidth,
      height: _outputHeight,
      maintainAspect: false,
    );

    // ----------------------------------------------------------
    // 14. Encode PNG
    // ----------------------------------------------------------

    final pngBytes = img.encodePng(
      resized,
    );

    debugPrint(
      '✅ Route map generated: '
      '${pngBytes.length} bytes',
    );

    return Uint8List.fromList(
      pngBytes,
    );
  }

  // ============================================================
  // Clean points
  // ============================================================

  List<LatLng> _cleanPoints(
    List<LatLng> points,
  ) {
    return points.where(
      (point) {
        return point.latitude.isFinite &&
            point.longitude.isFinite &&
            point.latitude >= -85 &&
            point.latitude <= 85 &&
            point.longitude >= -180 &&
            point.longitude <= 180 &&
            !(point.latitude == 0 &&
                point.longitude == 0);
      },
    ).toList();
  }

  // ============================================================
  // Calculate Bounds
  // ============================================================

  _RouteBounds _calculateBounds(
    List<LatLng> points,
  ) {
    double minLat =
        points.first.latitude;

    double maxLat =
        points.first.latitude;

    double minLng =
        points.first.longitude;

    double maxLng =
        points.first.longitude;

    for (final point in points) {
      minLat = math.min(
        minLat,
        point.latitude,
      );

      maxLat = math.max(
        maxLat,
        point.latitude,
      );

      minLng = math.min(
        minLng,
        point.longitude,
      );

      maxLng = math.max(
        maxLng,
        point.longitude,
      );
    }

    // ----------------------------------------------------------
    // Padding
    // ----------------------------------------------------------

    final latSpan =
        maxLat - minLat;

    final lngSpan =
        maxLng - minLng;

    final latPadding =
        math.max(
      latSpan * _paddingFactor,
      _minimumLatPadding,
    );

    final lngPadding =
        math.max(
      lngSpan * _paddingFactor,
      _minimumLngPadding,
    );

    return _RouteBounds(
      minLat: math.max(
        -85,
        minLat - latPadding,
      ),
      maxLat: math.min(
        85,
        maxLat + latPadding,
      ),
      minLng: math.max(
        -180,
        minLng - lngPadding,
      ),
      maxLng: math.min(
        180,
        maxLng + lngPadding,
      ),
    );
  }

  // ============================================================
  // Auto Zoom
  //
  // Finds the highest zoom that allows the complete route
  // to fit comfortably inside the final PDF map.
  // ============================================================

  int _calculateAutoZoom(
    _RouteBounds bounds,
  ) {
    final latSpan =
        bounds.maxLat -
        bounds.minLat;

    final lngSpan =
        bounds.maxLng -
        bounds.minLng;

    if (!latSpan.isFinite ||
        !lngSpan.isFinite ||
        latSpan <= 0 ||
        lngSpan <= 0) {
      return 13;
    }

    // We intentionally use only part of the final image
    // so the route does not touch the edges.
    const availableWidth =
        _outputWidth * 0.80;

    const availableHeight =
        _outputHeight * 0.80;

    for (
      int zoom = _maxZoom;
      zoom >= _minZoom;
      zoom--
    ) {
      final worldSize =
          _tileSize *
          math.pow(
            2,
            zoom,
          ).toDouble();

      final minX =
          _longitudeToPixel(
        bounds.minLng,
        worldSize,
      );

      final maxX =
          _longitudeToPixel(
        bounds.maxLng,
        worldSize,
      );

      final minY =
          _latitudeToPixel(
        bounds.maxLat,
        worldSize,
      );

      final maxY =
          _latitudeToPixel(
        bounds.minLat,
        worldSize,
      );

      final pixelWidth =
          (maxX - minX).abs();

      final pixelHeight =
          (maxY - minY).abs();

      if (pixelWidth <=
              availableWidth &&
          pixelHeight <=
              availableHeight) {
        return zoom;
      }
    }

    return _minZoom;
  }

  // ============================================================
  // Longitude -> World Pixel
  // ============================================================

  double _longitudeToPixel(
    double longitude,
    double worldSize,
  ) {
    return (longitude + 180) /
        360 *
        worldSize;
  }

  // ============================================================
  // Latitude -> World Pixel
  // ============================================================

  double _latitudeToPixel(
    double latitude,
    double worldSize,
  ) {
    final safeLatitude =
        latitude.clamp(
      -85.05112878,
      85.05112878,
    );

    final latRad =
        safeLatitude *
        math.pi /
        180;

    return (
          1 -
          math.log(
                math.tan(latRad) +
                    (1 /
                        math.cos(
                          latRad,
                        )),
              ) /
              math.pi
        ) /
        2 *
        worldSize;
  }

  // ============================================================
  // Tile Range
  // ============================================================

  _TileRange _calculateTileRange(
    _RouteBounds bounds,
    int zoom,
  ) {
    final minTile =
        _latLngToTile(
      bounds.maxLat,
      bounds.minLng,
      zoom,
    );

    final maxTile =
        _latLngToTile(
      bounds.minLat,
      bounds.maxLng,
      zoom,
    );

    return _TileRange(
      minX: minTile.x,
      maxX: maxTile.x,
      minY: minTile.y,
      maxY: maxTile.y,
    );
  }

  // ============================================================
  // LatLng -> Tile coordinates
  // ============================================================

  _TileCoordinate _latLngToTile(
    double latitude,
    double longitude,
    int zoom,
  ) {
    final safeLatitude =
        latitude.clamp(
      -85.05112878,
      85.05112878,
    );

    final latRad =
        safeLatitude *
        math.pi /
        180;

    final n =
        math.pow(
          2,
          zoom,
        ).toDouble();

    final x =
        ((longitude + 180) /
                360 *
                n)
            .floor();

    final y =
        (
              1 -
              math.log(
                    math.tan(latRad) +
                        (1 /
                            math.cos(
                              latRad,
                            )),
                  ) /
                  math.pi
            ) /
            2 *
            n;

    return _TileCoordinate(
      x: x,
      y: y.floor(),
    );
  }

  // ============================================================
  // Download + Compose Tiles
  // ============================================================

  Future<img.Image>
      _downloadAndComposeTiles(
    _TileRange range,
    int zoom,
  ) async {
    final tilesWide =
        range.maxX -
        range.minX +
        1;

    final tilesHigh =
        range.maxY -
        range.minY +
        1;

    final width =
        tilesWide *
        _tileSize;

    final height =
        tilesHigh *
        _tileSize;

    final canvas = img.Image(
      width: width,
      height: height,
    );

    img.fill(
      canvas,
      color: img.ColorRgb8(
        245,
        245,
        245,
      ),
    );

    int serverIndex = 0;

    int successfulTiles = 0;

    int failedTiles = 0;

    // ----------------------------------------------------------
    // Download tiles
    // ----------------------------------------------------------

    for (
      int y = range.minY;
      y <= range.maxY;
      y++
    ) {
      for (
        int x = range.minX;
        x <= range.maxX;
        x++
      ) {
        final server =
            _tileServers[
              serverIndex %
                  _tileServers.length
            ];

        serverIndex++;

        final tileUrl =
            '$server/'
            '$zoom/'
            '$x/'
            '$y.png';

        try {
          debugPrint(
            '⬇️ Download tile: '
            '$tileUrl',
          );

          final response =
              await _dio.get<List<int>>(
            tileUrl,
            options: Options(
              responseType:
                  ResponseType.bytes,
              headers: {
                'User-Agent':
                    'ColdChainShield/1.0 '
                    '(trip-report-map)',
                'Accept':
                    'image/png,image/*',
              },
              validateStatus:
                  (status) {
                return status != null &&
                    status >= 200 &&
                    status < 300;
              },
            ),
          );

          debugPrint(
            '📡 Tile response: '
            'status=${response.statusCode}, '
            'bytes=${response.data?.length ?? 0}, '
            'type=${response.headers.value('content-type')}',
          );

          final data =
              response.data;

          if (data == null ||
              data.isEmpty) {
            failedTiles++;

            debugPrint(
              '❌ Empty tile response: '
              '$tileUrl',
            );

            continue;
          }

          final tileBytes =
              Uint8List.fromList(
            data,
          );

          final tile =
              img.decodeImage(
            tileBytes,
          );

          if (tile == null) {
            failedTiles++;

            debugPrint(
              '❌ Could not decode tile: '
              '$tileUrl',
            );

            continue;
          }

          final offsetX =
              (x - range.minX) *
              _tileSize;

          final offsetY =
              (y - range.minY) *
              _tileSize;

          img.compositeImage(
            canvas,
            tile,
            dstX: offsetX,
            dstY: offsetY,
          );

          successfulTiles++;

          debugPrint(
            '✅ Tile added: '
            'x=$x y=$y',
          );
        } catch (e) {
          failedTiles++;

          debugPrint(
            '❌ Tile download failed:\n'
            'x=$x y=$y\n'
            'URL=$tileUrl\n'
            'ERROR=$e',
          );
        }
      }
    }

    debugPrint(
      '🗺️ Tile composition finished: '
      'success=$successfulTiles '
      'failed=$failedTiles '
      'total=${successfulTiles + failedTiles}',
    );

    if (successfulTiles == 0) {
      throw Exception(
        'Could not download any map tiles.',
      );
    }

    return canvas;
  }

  // ============================================================
  // Project LatLng -> Image Pixels
  // ============================================================

  _PixelPoint _projectPoint(
    LatLng point,
    _TileRange range,
    int zoom,
  ) {
    final worldSize =
        _tileSize *
        math.pow(
          2,
          zoom,
        ).toDouble();

    final x =
        _longitudeToPixel(
      point.longitude,
      worldSize,
    );

    final y =
        _latitudeToPixel(
      point.latitude,
      worldSize,
    );

    final offsetX =
        range.minX *
        _tileSize;

    final offsetY =
        range.minY *
        _tileSize;

    return _PixelPoint(
      x: (x - offsetX).round(),
      y: (y - offsetY).round(),
    );
  }

  // ============================================================
  // Draw Route
  // ============================================================

  void _drawRoute(
    img.Image image,
    List<_PixelPoint> points,
  ) {
    if (points.length < 2) {
      return;
    }

    // ----------------------------------------------------------
    // Black outline / shadow
    // ----------------------------------------------------------

    for (
      int i = 0;
      i < points.length - 1;
      i++
    ) {
      img.drawLine(
        image,
        x1: points[i].x,
        y1: points[i].y,
        x2: points[i + 1].x,
        y2: points[i + 1].y,
        color: img.ColorRgb8(
          0,
          0,
          0,
        ),
        thickness: 8,
      );
    }

    // ----------------------------------------------------------
    // Main route - cyan
    // ----------------------------------------------------------

    final routeColor =
        img.ColorRgb8(
      0,
      180,
      255,
    );

    for (
      int i = 0;
      i < points.length - 1;
      i++
    ) {
      img.drawLine(
        image,
        x1: points[i].x,
        y1: points[i].y,
        x2: points[i + 1].x,
        y2: points[i + 1].y,
        color: routeColor,
        thickness: 5,
      );
    }
  }

  // ============================================================
  // Start Marker
  // ============================================================

  void _drawStartMarker(
    img.Image image,
    _PixelPoint point,
  ) {
    // Outer green circle
    img.drawCircle(
      image,
      x: point.x,
      y: point.y,
      radius: 14,
      color: img.ColorRgb8(
        0,
        190,
        90,
      ),
      antialias: true,
    );

    // White center
    img.drawCircle(
      image,
      x: point.x,
      y: point.y,
      radius: 6,
      color: img.ColorRgb8(
        255,
        255,
        255,
      ),
      antialias: true,
    );
  }

  // ============================================================
  // End Marker
  // ============================================================

  void _drawEndMarker(
    img.Image image,
    _PixelPoint point,
  ) {
    // Outer red circle
    img.drawCircle(
      image,
      x: point.x,
      y: point.y,
      radius: 14,
      color: img.ColorRgb8(
        220,
        50,
        50,
      ),
      antialias: true,
    );

    // White center
    img.drawCircle(
      image,
      x: point.x,
      y: point.y,
      radius: 6,
      color: img.ColorRgb8(
        255,
        255,
        255,
      ),
      antialias: true,
    );
  }

  // ============================================================
  // Legend
  //
  // Drawn directly on the map image.
  //
  // Green circle = START
  // Red circle   = END
  // ============================================================

  void _drawLegend(
    img.Image image,
  ) {
    const int legendWidth = 190;
    const int legendHeight = 72;

    const int margin = 15;

    final x1 = margin;
    final y1 = margin;

    final x2 =
        x1 + legendWidth;

    final y2 =
        y1 + legendHeight;

    // ----------------------------------------------------------
    // White translucent background
    // ----------------------------------------------------------

    img.fillRect(
      image,
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      color: img.ColorRgba8(
        255,
        255,
        255,
        235,
      ),
    );

    // ----------------------------------------------------------
    // Border
    // ----------------------------------------------------------

    img.drawRect(
      image,
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      color: img.ColorRgb8(
        180,
        180,
        180,
      ),
      thickness: 2,
    );

    // ----------------------------------------------------------
    // START marker
    // ----------------------------------------------------------

    img.drawCircle(
      image,
      x: x1 + 20,
      y: y1 + 22,
      radius: 9,
      color: img.ColorRgb8(
        0,
        190,
        90,
      ),
      antialias: true,
    );

    img.drawCircle(
      image,
      x: x1 + 20,
      y: y1 + 22,
      radius: 4,
      color: img.ColorRgb8(
        255,
        255,
        255,
      ),
      antialias: true,
    );

    img.drawString(
      image,
      'START',
      font: img.arial14,
      x: x1 + 38,
      y: y1 + 15,
      color: img.ColorRgb8(
        40,
        40,
        40,
      ),
    );

    // ----------------------------------------------------------
    // END marker
    // ----------------------------------------------------------

    img.drawCircle(
      image,
      x: x1 + 20,
      y: y1 + 50,
      radius: 9,
      color: img.ColorRgb8(
        220,
        50,
        50,
      ),
      antialias: true,
    );

    img.drawCircle(
      image,
      x: x1 + 20,
      y: y1 + 50,
      radius: 4,
      color: img.ColorRgb8(
        255,
        255,
        255,
      ),
      antialias: true,
    );

    img.drawString(
      image,
      'END',
      font: img.arial14,
      x: x1 + 38,
      y: y1 + 43,
      color: img.ColorRgb8(
        40,
        40,
        40,
      ),
    );
  }

  // ============================================================
  // Attribution
  // ============================================================

  void _drawAttribution(
    img.Image image,
  ) {
    const text =
        'OpenStreetMap contributors';

    final attributionHeight = 30;

    img.fillRect(
      image,
      x1: 0,
      y1: image.height -
          attributionHeight,
      x2: image.width,
      y2: image.height,
      color: img.ColorRgba8(
        255,
        255,
        255,
        220,
      ),
    );

    img.drawString(
      image,
      text,
      font: img.arial14,
      x: 10,
      y: image.height - 23,
      color: img.ColorRgb8(
        50,
        50,
        50,
      ),
    );
  }

  // ============================================================
  // Single Point Fallback
  // ============================================================

  Future<Uint8List>
      _generateSinglePointMap(
    LatLng point,
  ) async {
    const delta = 0.01;

    final bounds =
        _RouteBounds(
      minLat:
          math.max(
        -85,
        point.latitude - delta,
      ),
      maxLat:
          math.min(
        85,
        point.latitude + delta,
      ),
      minLng:
          math.max(
        -180,
        point.longitude - delta,
      ),
      maxLng:
          math.min(
        180,
        point.longitude + delta,
      ),
    );

    final zoom =
        _calculateAutoZoom(
      bounds,
    );

    debugPrint(
      '🔍 Single point Auto Zoom = $zoom',
    );

    final range =
        _calculateTileRange(
      bounds,
      zoom,
    );

    final image =
        await _downloadAndComposeTiles(
      range,
      zoom,
    );

    final pixel =
        _projectPoint(
      point,
      range,
      zoom,
    );

    _drawStartMarker(
      image,
      pixel,
    );

    _drawLegend(
      image,
    );

    _drawAttribution(
      image,
    );

    final resized =
        img.copyResize(
      image,
      width: _outputWidth,
      height: _outputHeight,
      maintainAspect: false,
    );

    return Uint8List.fromList(
      img.encodePng(
        resized,
      ),
    );
  }
}

// ============================================================
// Internal Classes
// ============================================================

class _RouteBounds {
  final double minLat;
  final double maxLat;

  final double minLng;
  final double maxLng;

  const _RouteBounds({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });
}

class _TileCoordinate {
  final int x;
  final int y;

  const _TileCoordinate({
    required this.x,
    required this.y,
  });
}

class _TileRange {
  final int minX;
  final int maxX;

  final int minY;
  final int maxY;

  const _TileRange({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });
}

class _PixelPoint {
  final int x;
  final int y;

  const _PixelPoint({
    required this.x,
    required this.y,
  });
}


