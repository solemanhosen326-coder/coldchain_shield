import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:coldchain_shield/Auth/login_page.dart';
import 'package:coldchain_shield/model.dart';

import 'package:coldchain_shield/features/driver/driver_home.dart';
import 'package:coldchain_shield/features/driver/trip_provider.dart';

import 'package:coldchain_shield/features/enterprise/pages/enterprise_home_page.dart';

class AppHomeGate extends StatefulWidget {
  const AppHomeGate({super.key});

  @override
  State<AppHomeGate> createState() => _AppHomeGateState();
}

class _AppHomeGateState extends State<AppHomeGate> {
  late Future<Widget> _homeFuture;

  @override
  void initState() {
    super.initState();

    _homeFuture = _checkHome();
  }

  Future<Widget> _checkHome() async {
    try {
      // ============================================================
      // 1️⃣ Firebase Authentication
      // ============================================================

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint('🔴 HOME CHECK 1: No authenticated user.');

        return const LoginPage();
      }

      final uid = user.uid.trim();

      if (uid.isEmpty) {
        debugPrint('🔴 HOME CHECK 1: Invalid UID.');

        await FirebaseAuth.instance.signOut();

        return const LoginPage();
      }

      debugPrint('🟢 HOME CHECK 1: Authenticated UID = $uid');

      // ============================================================
      // 2️⃣ Firestore
      // ============================================================

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        debugPrint('🔴 HOME CHECK 2: User document does not exist.');

        await FirebaseAuth.instance.signOut();

        return const LoginPage();
      }

      final data = userDoc.data()!;

      final role = (data['role'] as String?)?.trim().toLowerCase();

      if (role == null || role.isEmpty) {
        debugPrint('🔴 HOME CHECK 2: Role is missing.');

        await FirebaseAuth.instance.signOut();

        return const LoginPage();
      }

      final bool firestoreDriver = role == 'driver';

      final bool firestoreEnterprise =
          role == 'enterprise' || role == 'company';

      if (!firestoreDriver && !firestoreEnterprise) {
        debugPrint('🔴 HOME CHECK 2: Unknown role = $role');

        await FirebaseAuth.instance.signOut();

        return const LoginPage();
      }

      debugPrint('🟢 HOME CHECK 2: Firestore role = $role');

      // ============================================================
      // 3️⃣ Provider
      // ============================================================

      final model = context.read<Model>();

      final providerRole = model.isDriverRole;

      debugPrint(
        '🟡 HOME CHECK 3: Provider role = '
        '${providerRole == null
            ? 'unknown'
            : providerRole
            ? 'driver'
            : 'enterprise'}',
      );

      // ------------------------------------------------------------
      // Provider is empty after app restart.
      // Initialize it from Firestore.
      // ------------------------------------------------------------

      if (providerRole == null) {
        model.setFinalRole(firestoreDriver);

        debugPrint(
          '🟡 HOME CHECK 3: Provider was null. '
          'Initialized from Firestore = $role',
        );
      }
      // ------------------------------------------------------------
      // Provider already has a role.
      // Verify it against Firestore.
      // ------------------------------------------------------------
      else if (providerRole != firestoreDriver) {
        debugPrint('🔴 HOME CHECK 3: Role mismatch.');

        debugPrint(
          '   Provider = '
          '${providerRole ? 'driver' : 'enterprise'}',
        );

        debugPrint('   Firestore = $role');

        await FirebaseAuth.instance.signOut();

        model.clearRole();

        return const LoginPage();
      }

      debugPrint('🟢 HOME CHECK 3: Provider role verified.');

      // ============================================================
      // 4️⃣ Driver
      // ============================================================

      if (firestoreDriver) {
        debugPrint('🟢 HOME: Loading driver data...');

        final tripProvider = context.read<TripProvider>();

        await tripProvider.loadDriverData();

        if (tripProvider.driver == null) {
          debugPrint('🔴 HOME: Driver data could not be loaded.');

          await FirebaseAuth.instance.signOut();

          model.clearRole();

          return const LoginPage();
        }

        debugPrint('🟢 HOME: Driver verified.');

        return const DriverHomePage();
      }

      // ============================================================
      // 5️⃣ Enterprise
      // ============================================================

      if (firestoreEnterprise) {
        debugPrint('🟢 HOME: Enterprise verified.');

        return const EnterpriseHomePage();
      }

      // ============================================================
      // Safety fallback
      // ============================================================

      await FirebaseAuth.instance.signOut();

      model.clearRole();

      return const LoginPage();
    } catch (e, stackTrace) {
      debugPrint('❌ HOME CHECK ERROR: $e');

      debugPrintStack(stackTrace: stackTrace);

      return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _homeFuture,
      builder: (context, snapshot) {
        // ==========================================================
        // Loading
        // ==========================================================

        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: const Color(0xFF02060A),
            body: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Color(0xFF071A26),
                    Color(0xFF02060A),
                    Color(0xFF000000),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ==================================================
                    // Crystal logo / glow
                    // ==================================================
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF00E5FF), Color(0xFF0077FF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withOpacity(0.35),
                            blurRadius: 35,
                            spreadRadius: 8,
                          ),
                          BoxShadow(
                            color: const Color(0xFF0077FF).withOpacity(0.20),
                            blurRadius: 60,
                            spreadRadius: 15,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // Project name
                    // ==================================================
                    const Text(
                      'COLDCHAIN SHIELD',
                      style: TextStyle(
                        color: Color(0xFF00E5FF),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'رادار الإمداد الذكي وسلاسل التبريد',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),

                    const SizedBox(height: 35),

                    // ==================================================
                    // Loading indicator
                    // ==================================================
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00E5FF),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'جاري التحقق من بيانات الحساب...',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // ==========================================================
        // Error
        // ==========================================================

        if (snapshot.hasError) {
          debugPrint('❌ HOME FUTURE ERROR: ${snapshot.error}');

          return const LoginPage();
        }

        // ==========================================================
        // Final Page
        // ==========================================================

        return snapshot.data ?? const LoginPage();
      },
    );
  }
}
