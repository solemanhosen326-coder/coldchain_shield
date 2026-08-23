import 'package:coldchain_shield/features/enterprise/enterprise_provider.dart';
import 'package:coldchain_shield/features/enterprise/widgets/dashboard_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardOverview extends StatelessWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Row(
          children: [

            Selector<EnterpriseProvider, int>(
              selector: (_, provider) => provider.trucksCount,
              builder: (_, value, __) {
                return DashboardCard(
                  icon: Icons.local_shipping,
                  title: "Trucks",
                  value: value.toString(),
                  color: Colors.cyanAccent,
                );
              },
            ),

            Selector<EnterpriseProvider, int>(
              selector: (_, provider) => provider.driversCount,
              builder: (_, value, __) {
                return DashboardCard(
                  icon: Icons.person,
                  title: "Drivers",
                  value: value.toString(),
                  color: Colors.greenAccent,
                );
              },
            ),
          ],
        ),

        Row(
          children: [

            Selector<EnterpriseProvider, int>(
              selector: (_, provider) => provider.overheatingCount,
              builder: (_, value, __) {
                return DashboardCard(
                  icon: Icons.warning_amber_rounded,
                  title: "Alerts",
                  value: value.toString(),
                  color: Colors.redAccent,
                );
              },
            ),

            Selector<EnterpriseProvider, int>(
              selector: (_, provider) => provider.packetsCount,
              builder: (_, value, __) {
                return DashboardCard(
                  icon: Icons.cloud_done,
                  title: "Packets",
                  value: value.toString(),
                  color: Colors.orangeAccent,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}