import 'package:coldchain_shield/features/enterprise/models/enterprise_model.dart';
import 'package:flutter/material.dart';

class CompanyCard extends StatelessWidget {
  final EnterpriseModel? enterprise;

  const CompanyCard({
    super.key,
    required this.enterprise,
  });

  @override
  Widget build(BuildContext context) {
    const Color crystalBlue = Color(0xFF00E5FF);

    final companyName = enterprise?.companyName;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: crystalBlue.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: crystalBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.business_outlined,
              color: crystalBlue,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Company",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  companyName?.isNotEmpty == true
                      ? companyName!
                      : "No company assigned",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


