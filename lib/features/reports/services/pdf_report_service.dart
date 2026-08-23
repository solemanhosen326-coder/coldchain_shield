
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/trip_report_model.dart';
import '../services/trip_route_map_service.dart';

class PdfReportService {
  static Future<Uint8List> generateTripReport(
    TripReportModel report,
  ) async {
    final pdf = pw.Document();

    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");

    // ============================================================
    // Generate Route Map
    // ============================================================

    Uint8List? routeMapBytes;

    try {
      if  (report.route.isNotEmpty) {
        debugPrint(
          "🗺️ Generating PDF route map..."
          " Points = ${report.route.length}",
        );

        routeMapBytes =
            await TripRouteMapService().generateRouteMap(
          points: report.route,
        );

        debugPrint(
          "✅ PDF route map generated: "
          "${routeMapBytes.length} bytes",
        );
      }
    } catch (e) {
      debugPrint(
        "⚠️ Failed to generate PDF route map: $e",
      );

      routeMapBytes = null;
    }

    final pw.MemoryImage? routeMapImage =
        routeMapBytes != null
            ? pw.MemoryImage(routeMapBytes)
            : null;

    // ============================================================
    // Duration formatter
    // ============================================================

    String formatDuration(Duration duration) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);

      if (hours > 0) {
        return "$hours h $minutes min";
      }

      return "$minutes min";
    }

    // ============================================================
    // PDF
    // ============================================================

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),

        // ========================================================
        // Header
        // ========================================================

        header: (context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(
              bottom: 20,
            ),
            child: pw.Row(
              mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "COLDCHAIN SHIELD",
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight:
                        pw.FontWeight.bold,
                    color: PdfColors.cyan,
                  ),
                ),

                pw.Text(
                  "TRIP REPORT",
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          );
        },

        // ========================================================
        // Footer
        // ========================================================

        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(
              top: 15,
            ),
            child: pw.Text(
              "ColdChain Shield - Page ${context.pageNumber}",
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey600,
              ),
            ),
          );
        },

        // ========================================================
        // Body
        // ========================================================

        build: (context) {
          return [
            // ======================================================
            // Title
            // ======================================================

            pw.Text(
              "Trip Report",
              style: pw.TextStyle(
                fontSize: 26,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Text(
              "Generated on "
              "${dateFormat.format(DateTime.now())}",
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),

            pw.SizedBox(height: 25),

            // ======================================================
            // Trip Information
            // ======================================================

            pw.Text(
              "Trip Information",
              style: pw.TextStyle(
                fontSize: 17,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey300,
              ),
              children: [
                _row(
                  "Trip ID",
                  report.tripId,
                ),
                _row(
                  "Company",
                  report.companyName,
                ),
                _row(
                  "Company ID",
                  report.companyId,
                ),
                _row(
                  "Driver",
                  report.driverName,
                ),
                _row(
                  "Driver ID",
                  report.driverId,
                ),
                _row(
                  "Truck ID",
                  report.truckId,
                ),
                _row(
                  "Status",
                  report.status,
                ),
                _row(
                  "Start Time",
                  dateFormat.format(
                    report.startTime,
                  ),
                ),
                _row(
                  "End Time",
                  report.endTime == null
                      ? "Not completed"
                      : dateFormat.format(
                          report.endTime!,
                        ),
                ),
                _row(
                  "Duration",
                  formatDuration(
                    report.duration,
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            // ======================================================
            // Trip Route Map
            // ======================================================

            if (routeMapImage != null) ...[
              pw.Text(
                "Trip Route",
                style: pw.TextStyle(
                  fontSize: 17,
                  fontWeight:
                      pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 12),

              pw.Container(
                width: double.infinity,
                height: 350,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey300,
                  ),
                  borderRadius:
                      pw.BorderRadius.circular(8),
                ),
                child: pw.ClipRRect(
                  horizontalRadius: 8,
                  verticalRadius: 8,
                  child: pw.Image(
                    routeMapImage,
                    fit: pw.BoxFit.cover,
                  ),
                ),
              ),

              pw.SizedBox(height: 8),

              pw.Text(
                "Route map - "
                "OpenStreetMap contributors",
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),

              pw.SizedBox(height: 30),
            ],

            // ======================================================
            // Statistics
            // ======================================================

            pw.Text(
              "Trip Statistics",
              style: pw.TextStyle(
                fontSize: 17,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 12),

            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey300,
              ),
              children: [
                _row(
                  "Tracking Points",
                  report.packetCount.toString(),
                ),

                _row(
                  "Average Speed",
                  "${report.averageSpeed.toStringAsFixed(2)} km/h",
                ),

                _row(
                  "Maximum Speed",
                  "${report.maxSpeed.toStringAsFixed(2)} km/h",
                ),

                _row(
                  "Average Temperature",
                  "${report.averageTemperature.toStringAsFixed(2)} °C",
                ),

                _row(
                  "Minimum Temperature",
                  "${report.minTemperature.toStringAsFixed(2)} °C",
                ),

                _row(
                  "Maximum Temperature",
                  "${report.maxTemperature.toStringAsFixed(2)} °C",
                ),
              ],
            ),

            pw.SizedBox(height: 35),

            // ======================================================
            // Summary
            // ======================================================

            pw.Text(
              "Summary",
              style: pw.TextStyle(
                fontSize: 17,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Container(
              padding:
                  const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius:
                    pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                "This report summarizes the "
                "recorded trip data including "
                "company and driver information, "
                "trip duration, route, speed "
                "statistics and temperature "
                "monitoring.",
                style: const pw.TextStyle(
                  fontSize: 11,
                  lineSpacing: 4,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ============================================================
  // Table Row
  // ============================================================

  static pw.TableRow _row(
    String title,
    String value,
  ) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding:
              const pw.EdgeInsets.all(8),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontWeight:
                  pw.FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),

        pw.Padding(
          padding:
              const pw.EdgeInsets.all(8),
          child: pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}




