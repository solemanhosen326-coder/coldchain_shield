import 'package:coldchain_shield/features/enterprise/analytics_provider.dart';
import 'package:coldchain_shield/features/enterprise/enterprise_provider.dart';
import 'package:coldchain_shield/features/enterprise/widgets/analytics/analytics_charts_provider.dart';
import 'package:coldchain_shield/features/enterprise/widgets/analytics/analytics_summary_card.dart';
import 'package:coldchain_shield/features/enterprise/widgets/analytics/analytics_temperature_card.dart';
import 'package:coldchain_shield/features/enterprise/widgets/analytics/analytics_speed_card.dart';
import 'package:coldchain_shield/features/enterprise/widgets/analytics/analytics_distance_card.dart';
import 'package:coldchain_shield/features/enterprise/widgets/analytics/analytics_trip_card.dart';
import 'package:coldchain_shield/features/enterprise/widgets/analytics/analytics_charts_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final enterprise = context.read<EnterpriseProvider>().enterprise;

      if (enterprise != null) {
        context.read<AnalyticsProvider>().loadAnalytics(enterprise.companyId);

        context.read<AnalyticsChartsProvider>().loadCharts(
          enterprise.companyId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B1220),

      appBar: AppBar(
        title: const Text("Analytics Dashboard"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Consumer<AnalyticsProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final analytics = provider.analytics;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AnalyticsSummaryCard(analytics: analytics),

              const SizedBox(height: 20),

              AnalyticsTripCard(analytics: analytics),

              const SizedBox(height: 20),

              AnalyticsTemperatureCard(analytics: analytics),

              const SizedBox(height: 20),

              AnalyticsSpeedCard(analytics: analytics),

              const SizedBox(height: 20),

              AnalyticsDistanceCard(analytics: analytics),

              const SizedBox(height: 20),

              Consumer<AnalyticsChartsProvider>(
                builder: (_, provider, __) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return AnalyticsChartsCard(charts: provider.charts);
                },
              ),

              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}
