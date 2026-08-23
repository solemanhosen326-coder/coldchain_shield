import 'package:coldchain_shield/constants/app_constants.dart';
import 'package:flutter/material.dart';


class TripControlButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onPressed;

  const TripControlButton({
    super.key,
    required this.isActive,
    required this.onPressed,
  });
 

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: isActive
              ? [
                  Colors.redAccent.withValues(alpha: .8),
                  const Color(0xFFFF1744),
                ]
              : [
                  const Color(0xFF0052D4),
                  const Color(0xFF00E5FF),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isActive ? Colors.red : AppColors.crystalBlue)
                .withValues(alpha: .35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: MaterialButton(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          isActive ? "إنهاء الرحلة" : "بدء الرحلة",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}