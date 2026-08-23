import 'package:coldchain_shield/features/driver/services/driver_join_request_service.dart';
import 'package:coldchain_shield/features/enterprise/assign_truck_dialog.dart';
import 'package:coldchain_shield/features/enterprise/enterprise_provider.dart';
import 'package:coldchain_shield/features/enterprise/models/driver_join_request_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnterpriseJoinRequestsPage extends StatelessWidget {
  const EnterpriseJoinRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final enterprise = context.watch<EnterpriseProvider>().enterprise;

    if (enterprise == null) {
      return const Scaffold(
        backgroundColor: Color(0xff0B1220),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final companyId = enterprise.companyId;
    debugPrint(" ENTERPRISE COMPANY ID: $companyId");

    return Scaffold(
      backgroundColor: const Color(0xff0B1220),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Driver Join Requests",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<List<DriverJoinRequestModel>>(
        stream: DriverJoinRequestService().companyRequestsStream(companyId),

        builder: (context, snapshot) {
          debugPrint(
            "📡 Stream state: ${snapshot.connectionState} | "
            "hasError: ${snapshot.hasError} | "
            "count: ${snapshot.data?.length}",
          );

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint("🔥 STREAM ERROR: ${snapshot.error}");
            return Center(
              child: Text(
                "Failed to load requests",
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            );
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_add_disabled_outlined,
                    color: Colors.white38,
                    size: 60,
                  ),

                  SizedBox(height: 15),

                  Text(
                    "No driver join requests",
                    style: TextStyle(color: Colors.white70, fontSize: 17),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: requests.length,

            itemBuilder: (context, index) {
              final request = requests[index];

              return _buildRequestCard(context, request);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    DriverJoinRequestModel request,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xff182233),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // =========================
          // Driver
          // =========================
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.person_outline,
                  color: Colors.cyanAccent,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      request.driverName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Driver ID: ${request.driverId}",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              _buildStatus(request),
            ],
          ),

          const SizedBox(height: 18),

          // =========================
          // Date
          // =========================
          Row(
            children: [
              const Icon(
                Icons.access_time_outlined,
                color: Colors.white54,
                size: 18,
              ),

              const SizedBox(width: 8),

              Text(
                _formatDate(request.createdAt),
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),

          // =========================
          // Actions
          // =========================
          if (request.isPending) ...[
            const SizedBox(height: 18),

            Row(
              children: [
                // ============================================================
                // Accept + Assign Truck
                // ============================================================
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            return AssignTruckDialog(
                              driverName: request.driverName,
                              onAssign: (truckId) async {
                                await DriverJoinRequestService().acceptRequest(
                                  requestId: request.requestId,
                                  truckId: truckId,
                                );
                              },
                            );
                          },
                        );

                        if (!context.mounted) return;

                        if (result == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "${request.driverName} assigned successfully",
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to accept request: $e"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text("Accept"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ============================================================
                // Reject
                // ============================================================
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await DriverJoinRequestService().rejectRequest(
                          request.requestId,
                        );

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Driver request rejected"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to reject request: $e"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text("Reject"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatus(DriverJoinRequestModel request) {
    Color color;
    String text;

    if (request.isPending) {
      color = Colors.orangeAccent;
      text = "Pending";
    } else if (request.isAccepted) {
      color = Colors.greenAccent;
      text = "Accepted";
    } else {
      color = Colors.redAccent;
      text = "Rejected";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');

    final minute = date.minute.toString().padLeft(2, '0');

    return "$day/$month/$year  $hour:$minute";
  }
}
