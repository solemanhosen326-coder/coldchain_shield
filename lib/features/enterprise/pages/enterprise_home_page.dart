import 'package:coldchain_shield/app/app_home_gate.dart';
import 'package:coldchain_shield/features/enterprise/enterprise_provider.dart';
import 'package:coldchain_shield/features/enterprise/pages/analytics_page.dart';
import 'package:coldchain_shield/features/enterprise/pages/enterprise_join_requests_page.dart';
import 'package:coldchain_shield/features/enterprise/pages/enterprise_settings_page.dart';
import 'package:coldchain_shield/features/enterprise/pages/trips_history_page.dart';
import 'package:coldchain_shield/features/enterprise/widgets/dashboard_stats.dart';
import 'package:coldchain_shield/features/enterprise/widgets/enterprise_header.dart';
import 'package:coldchain_shield/features/enterprise/widgets/fleet_list.dart';
import 'package:coldchain_shield/model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnterpriseHomePage extends StatefulWidget {
  const EnterpriseHomePage({super.key});

  @override
  State<EnterpriseHomePage> createState() => _EnterpriseHomePageState();
}

class _EnterpriseHomePageState extends State<EnterpriseHomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnterpriseProvider>().loadEnterpriseData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B1220),

      drawer: Drawer(
        backgroundColor: const Color(0xff0B1220),
        child: SafeArea(
          child: Column(
            children: [
              const DrawerHeader(
                child: Text(
                  "COLDCHAIN SHIELD",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(
                  Icons.dashboard_outlined,
                  color: Colors.cyanAccent,
                ),
                title: const Text(
                  "لوحة القيادة",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.history, color: Colors.cyanAccent),
                title: const Text(
                  "تاريخ الرحلات",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TripsHistoryPage()),
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.cyanAccent,
                ),
                title: const Text(
                  "التحليلات",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AnalyticsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.person_add_alt_1_outlined,
                  color: Colors.cyanAccent,
                ),
                title: const Text(
                  "طلبات الانضمام للسائقين",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EnterpriseJoinRequestsPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.settings_outlined,
                  color: Colors.cyanAccent,
                ),
                title: const Text(
                  "إعدادات الشركة",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EnterpriseSettingsPage(),
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
                    // 1. تنظيف الدور من Provider
                    // =========================================================

                    context.read<Model>().clearRole();

                    // =========================================================
                    // 2. تسجيل الخروج من Firebase Authentication
                    // =========================================================

                    await FirebaseAuth.instance.signOut();

                    if (!context.mounted) return;

                    // =========================================================
                    // 3. العودة إلى AppHomeGate
                    // =========================================================

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AppHomeGate()),
                      (route) => false,
                    );
                  } catch (e, stackTrace) {
                    debugPrint('❌ Enterprise logout error: $e');

                    debugPrintStack(stackTrace: stackTrace);
                  }
                },
              ),
            ],
          ),
        ),
      ),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Company Settings",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              EnterpriseHeader(),
              SizedBox(height: 25),
              DashboardStats(),
              SizedBox(height: 25),
              Text(
                "Fleet",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              FleetList(),
            ],
          ),
        ),
      ),
    );
  }
}
