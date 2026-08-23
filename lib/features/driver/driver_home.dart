import 'package:coldchain_shield/app/app_home_gate.dart';
import 'package:coldchain_shield/features/driver/driver_join_company_page.dart';
import 'package:coldchain_shield/features/driver/trip_provider.dart';
import 'package:coldchain_shield/features/driver/widgets/company_card.dart';
import 'package:coldchain_shield/features/driver/widgets/driver_header.dart';
import 'package:coldchain_shield/features/driver/widgets/temperature_card.dart';
import 'package:coldchain_shield/features/driver/widgets/trip_control_button.dart';
import 'package:coldchain_shield/features/driver/widgets/trip_statistics.dart';
import 'package:coldchain_shield/features/driver/widgets/trip_status_card.dart';
import 'package:coldchain_shield/model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().loadDriverData();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color bgBlack = Color(0xFF0B0E14);
    const Color crystalBlue = Color(0xFF00E5FF);
    const Color cyberBlue = Color(0xFF0052D4);

    return Scaffold(
      backgroundColor: bgBlack,

      // ============================================================
      // Driver Drawer
      // ============================================================
      drawer: Drawer(
        backgroundColor: const Color(0xFF0B1220),
        child: SafeArea(
          child: Column(
            children: [
              const DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      color: crystalBlue,
                      size: 50,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "COLDCHAIN SHIELD",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Driver Panel",
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),

              // ======================================================
              // Company Card
              // ======================================================
              Consumer<TripProvider>(
                builder: (context, provider, child) {
                  return CompanyCard(enterprise: provider.enterprise);
                },
              ),

              const SizedBox(height: 10),

              // ======================================================
              // Dashboard
              // ======================================================
              ListTile(
                leading: const Icon(
                  Icons.dashboard_outlined,
                  color: crystalBlue,
                ),
                title: const Text(
                  "لوحة القيادة",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              // ======================================================
              // Join Company
              // ======================================================
              ListTile(
                leading: const Icon(
                  Icons.business_outlined,
                  color: crystalBlue,
                ),
                title: const Text(
                  "انضم إلى الشركة",
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  "طلب الانضمام إلى شركة",
                  style: TextStyle(color: Colors.white54),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DriverJoinCompanyPage(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  // إغلاق Drawer أولًا
                  Navigator.of(context).pop();

                  try {
                    // =========================================================
                    // 1. إيقاف الرحلة إذا كانت فعالة
                    // =========================================================

                    final tripProvider = context.read<TripProvider>();

                    if (tripProvider.isTripActive) {
                      await tripProvider.stopTrip();
                    }

                    // =========================================================
                    // 2. تنظيف الدور من Provider
                    // =========================================================

                    context.read<Model>().clearRole();

                    // =========================================================
                    // 3. تسجيل الخروج من Firebase Authentication
                    // =========================================================

                    await FirebaseAuth.instance.signOut();

                    if (!context.mounted) return;

                    // =========================================================
                    // 4. العودة إلى AppHomeGate
                    //    ومنع الرجوع إلى DriverHomePage
                    // =========================================================

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AppHomeGate()),
                      (route) => false,
                    );
                  } catch (e, stackTrace) {
                    debugPrint('❌ Logout error: $e');
                    debugPrintStack(stackTrace: stackTrace);
                  }
                },
              ),
            ],
          ),
        ),
      ),

      // ============================================================
      // Main Content
      // ============================================================
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF081018), Color(0xFF0B0E14), Color(0xFF111827)],
          ),
        ),
        child: Stack(
          children: [
            // ========================================================
            // Glow أعلى اليمين
            // ========================================================
            Positioned(
              top: -120,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: crystalBlue.withValues(alpha: .12),
                      blurRadius: 140,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),

            // ========================================================
            // Glow أسفل اليسار
            // ========================================================
            Positioned(
              bottom: -120,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: cyberBlue.withValues(alpha: .12),
                      blurRadius: 120,
                      spreadRadius: 35,
                    ),
                  ],
                ),
              ),
            ),

            // ========================================================
            // Content
            // ========================================================
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // ==================================================
                      // Header
                      // ==================================================
                      const DriverHeader(),

                      const SizedBox(height: 4),

                      // ==================================================
                      // Temperature
                      // ==================================================
                      const TemperatureCard(),

                      const SizedBox(height: 10),

                      // ==================================================
                      // Trip Statistics
                      // ==================================================
                      const TripStatistics(),

                      const SizedBox(height: 10),

                      // ==================================================
                      // Trip Status
                      // ==================================================
                      const TripStatusCard(),

                      const SizedBox(height: 28),

                      // ==================================================
                      // Start / Stop Trip
                      // ==================================================
                      Selector<TripProvider, bool>(
                        selector: (context, provider) {
                          return provider.isTripActive;
                        },
                        builder: (context, isTripActive, child) {
                          return TripControlButton(
                            isActive: isTripActive,
                            onPressed: () {
                              context.read<TripProvider>().toggleTrip();
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      // ==================================================
                      // GPS / Trip Error
                      // ==================================================
                      Selector<TripProvider, String?>(
                        selector: (context, provider) {
                          return provider.tripError;
                        },
                        builder: (context, tripError, child) {
                          if (tripError == null || tripError.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return _TripErrorMessage(message: tripError);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// Trip Error Message
// ==================================================================

class _TripErrorMessage extends StatelessWidget {
  final String message;

  const _TripErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    const Color errorRed = Color(0xFFFF4D5A);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: errorRed.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: errorRed.withValues(alpha: 0.45), width: 1),
        boxShadow: [
          BoxShadow(
            color: errorRed.withValues(alpha: 0.08),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: errorRed.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_rounded,
              color: errorRed,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}




