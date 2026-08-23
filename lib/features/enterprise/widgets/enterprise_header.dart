import 'package:coldchain_shield/features/enterprise/enterprise_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnterpriseHeader extends StatelessWidget {
  const EnterpriseHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const crystalBlue = Color(0xFF00E5FF);
    return Selector<EnterpriseProvider, EnterpriseHeaderData>(
      selector: (_, provider) => EnterpriseHeaderData(
        companyName: provider.enterprise?.companyName ?? "Loading...",
        trucksCount: provider.trucksCount,
      ),
      builder: (_, data, __) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.04),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: crystalBlue.withOpacity(.15)),
          ),

          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: crystalBlue, width: 2),
                ),
                child: const Icon(
                  Icons.business,
                  color: Colors.white,
                  size: 34,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Enterprise Dashboard",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      data.companyName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.circle,
                              size: 10,
                              color: Colors.greenAccent,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "Live Monitoring",
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_shipping,
                              color: Colors.cyanAccent,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${data.trucksCount} Active Trucks",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EnterpriseHeaderData {
  final String companyName;
  final int trucksCount;

  const EnterpriseHeaderData({
    required this.companyName,
    required this.trucksCount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnterpriseHeaderData &&
          companyName == other.companyName &&
          trucksCount == other.trucksCount;

  @override
  int get hashCode => Object.hash(companyName, trucksCount);
}
