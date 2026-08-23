import 'package:coldchain_shield/features/driver/services/driver_join_request_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:coldchain_shield/features/driver/services/driver_service.dart';


class DriverJoinCompanyPage extends StatefulWidget {
  const DriverJoinCompanyPage({super.key});

  @override
  State<DriverJoinCompanyPage> createState() =>
      _DriverJoinCompanyPageState();
}

class _DriverJoinCompanyPageState
    extends State<DriverJoinCompanyPage> {
  final TextEditingController _companyIdController =
      TextEditingController();

  final DriverService _driverService = DriverService();
  final DriverJoinRequestService _joinRequestService =
      DriverJoinRequestService();

  bool _isLoading = false;

  @override
  void dispose() {
    _companyIdController.dispose();
    super.dispose();
  }

  Future<void> _sendJoinRequest() async {
    final companyId = _companyIdController.text.trim();

    if (companyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Company ID"),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final driver = await _driverService.getDriverData();

      if (driver == null) {
        throw Exception("Driver data not found");
      }

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("No authenticated driver");
      }

      await _joinRequestService.sendRequest(
        driverId: user.uid,
        driverName: driver.userName,
        companyId: companyId,
      );

      if (!mounted) return;

      _companyIdController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Join request sent successfully",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to send request: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B1220),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "Join Company",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Join a Company",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Enter the Company ID provided by the company owner "
              "to send a request to join the company.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xff182233),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _companyIdController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: "Company ID",
                      labelStyle: const TextStyle(
                        color: Colors.white70,
                      ),
                      hintText: "Enter Company ID",
                      hintStyle: const TextStyle(
                        color: Colors.white38,
                      ),
                      prefixIcon: const Icon(
                        Icons.business_outlined,
                        color: Colors.cyanAccent,
                      ),
                      filled: true,
                      fillColor: const Color(0xff0B1220),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed:
                          _isLoading ? null : _sendJoinRequest,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.send_outlined,
                            ),
                      label: Text(
                        _isLoading
                            ? "Sending..."
                            : "طلب الانضمام",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}