import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../models/trip_report_model.dart';
import '../services/pdf_report_service.dart';
import '../services/trip_report_data_service.dart';

class TripReportPage extends StatefulWidget {
  final String tripId;

  const TripReportPage({
    super.key,
    required this.tripId,
  });

  @override
  State<TripReportPage> createState() => _TripReportPageState();
}

class _TripReportPageState extends State<TripReportPage> {
  final TripReportDataService _dataService =
      TripReportDataService();

  bool _loading = true;
  String? _error;

  TripReportModel? _report;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  // ============================================================
  // Load Report
  // ============================================================

  Future<void> _loadReport() async {
    try {
      final report =
          await _dataService.buildReport(widget.tripId);

      if (!mounted) return;

      setState(() {
        _report = report;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ============================================================
  // Date Formatting
  // ============================================================

  String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    final year =
        date.year.toString();

    final hour =
        date.hour.toString().padLeft(2, '0');

    final minute =
        date.minute.toString().padLeft(2, '0');

    return "$day/$month/$year  $hour:$minute";
  }

  // ============================================================
  // Duration Formatting
  // ============================================================

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;

    final minutes =
        duration.inMinutes.remainder(60);

    if (hours > 0) {
      return "$hours h $minutes min";
    }

    return "$minutes min";
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xff0B1220);
    const cyan = Color(0xff00E5FF);

    // ============================================================
    // Loading
    // ============================================================

    if (_loading) {
      return const Scaffold(
        backgroundColor: bg,
        body: Center(
          child: CircularProgressIndicator(
            color: cyan,
          ),
        ),
      );
    }

    // ============================================================
    // Error
    // ============================================================

    if (_error != null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Trip Report",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 15,
              ),
            ),
          ),
        ),
      );
    }

    // ============================================================
    // Report
    // ============================================================

    final report = _report!;

    return Scaffold(
      backgroundColor: bg,

      // ==========================================================
      // AppBar
      // ==========================================================

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: const Text(
          "Trip Report",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.picture_as_pdf_outlined,
              color: cyan,
            ),
            onPressed: () async {
              try {
                final pdf =
                    await PdfReportService.generateTripReport(
                  report,
                );

                await Printing.sharePdf(
                  bytes: pdf,
                  filename:
                      "trip_report_${report.tripId}.pdf",
                );
              } catch (e) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      "Failed to generate PDF: $e",
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),

      // ==========================================================
      // Body
      // ==========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ======================================================
            // Trip Information
            // ======================================================

            _sectionTitle(
              "Trip Information",
            ),

            _infoCard(
              "Company",
              report.companyName.isEmpty
                  ? "Unknown Company"
                  : report.companyName,
              Icons.business_outlined,
            ),

            _infoCard(
              "Company ID",
              report.companyId,
              Icons.badge_outlined,
            ),

            _infoCard(
              "Driver",
              report.driverName,
              Icons.person_outline,
            ),

            _infoCard(
              "Driver ID",
              report.driverId,
              Icons.perm_identity_outlined,
            ),

            _infoCard(
              "Truck",
              report.truckId,
              Icons.local_shipping_outlined,
            ),

            _infoCard(
              "Status",
              report.status,
              Icons.flag_outlined,
            ),

            _infoCard(
              "Start Time",
              _formatDate(report.startTime),
              Icons.play_circle_outline,
            ),

            _infoCard(
              "End Time",
              report.endTime == null
                  ? "Not completed"
                  : _formatDate(
                      report.endTime!,
                    ),
              Icons.stop_circle_outlined,
            ),

            _infoCard(
              "Duration",
              _formatDuration(
                report.duration,
              ),
              Icons.timer_outlined,
            ),

            const SizedBox(height: 20),

            // ======================================================
            // Statistics
            // ======================================================

            _sectionTitle(
              "Statistics",
            ),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "Points",
                    "${report.packetCount}",
                    Icons.location_on_outlined,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _statCard(
                    "Avg Speed",
                    "${report.averageSpeed.toStringAsFixed(1)} km/h",
                    Icons.speed_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "Max Speed",
                    "${report.maxSpeed.toStringAsFixed(1)} km/h",
                    Icons.flash_on_outlined,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _statCard(
                    "Avg Temp",
                    "${report.averageTemperature.toStringAsFixed(1)} °C",
                    Icons.thermostat_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "Min Temp",
                    "${report.minTemperature.toStringAsFixed(1)} °C",
                    Icons.ac_unit_outlined,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _statCard(
                    "Max Temp",
                    "${report.maxTemperature.toStringAsFixed(1)} °C",
                    Icons.local_fire_department_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ======================================================
            // Generate PDF
            // ======================================================

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final pdf =
                        await PdfReportService
                            .generateTripReport(
                      report,
                    );

                    await Printing.layoutPdf(
                      onLayout: (_) async => pdf,
                    );
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          "Failed to generate PDF: $e",
                        ),
                      ),
                    );
                  }
                },

                icon: const Icon(
                  Icons.picture_as_pdf,
                ),

                label: const Text(
                  "إنشاء تقرير PDF",
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: cyan,
                  foregroundColor: Colors.black,

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 15,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Section Title
  // ============================================================

  Widget _sectionTitle(String title) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),

      child: Text(
        title,

        style: const TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // Information Card
  // ============================================================

  Widget _infoCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,

      margin:
          const EdgeInsets.only(bottom: 10),

      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xff182233),

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: Colors.white10,
        ),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xff00E5FF),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style:
                      const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value.isEmpty
                      ? "-"
                      : value,

                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Statistics Card
  // ============================================================

  Widget _statCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xff182233),

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: Colors.white10,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color:
                const Color(0xff00E5FF),
            size: 22,
          ),

          const SizedBox(height: 12),

          Text(
            title,

            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}