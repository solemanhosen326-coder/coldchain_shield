import 'package:coldchain_shield/app/app_home_gate.dart';
import 'package:coldchain_shield/constants/app_constants.dart';
import 'package:coldchain_shield/features/driver/trip_provider.dart';
import 'package:coldchain_shield/features/enterprise/analytics_provider.dart';
import 'package:coldchain_shield/features/enterprise/trip_history_provider.dart';
import 'package:coldchain_shield/features/enterprise/trip_packets_provider.dart';
import 'package:coldchain_shield/features/enterprise/trip_route_provider.dart';
import 'package:coldchain_shield/features/enterprise/trip_statistics_provider.dart';
import 'package:coldchain_shield/features/enterprise/truck_provider.dart';
import 'package:coldchain_shield/features/enterprise/widgets/analytics/analytics_charts_provider.dart';
import 'package:coldchain_shield/model.dart';
import 'package:coldchain_shield/features/enterprise/enterprise_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  if (!Hive.isBoxOpen(HiveBoxes.location)) {
    await Hive.openBox(HiveBoxes.location);
  }
  if (!Hive.isBoxOpen(HiveBoxes.session)) {
    await Hive.openBox(HiveBoxes.session);
  }

  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Model()),

        ChangeNotifierProvider(create: (_) => TripProvider()),

        ChangeNotifierProvider(create: (_) => EnterpriseProvider()),

        ChangeNotifierProvider(create: (_) => TripHistoryProvider()),

        ChangeNotifierProvider(create: (_) => TripStatisticsProvider()),

        ChangeNotifierProvider(create: (_) => TripRouteProvider()),

        ChangeNotifierProvider(create: (_) => TripPacketsProvider()),

        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),

        ChangeNotifierProvider(create: (_) => AnalyticsChartsProvider()),

        ChangeNotifierProvider(create: (_) => TruckProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AppHomeGate(),
    );
  }
}
