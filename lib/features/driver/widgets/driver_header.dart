import 'package:coldchain_shield/features/driver/models/driver_model.dart';
import 'package:coldchain_shield/features/driver/trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DriverHeader extends StatelessWidget {
  const DriverHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const Color crystalBlue = Color(0xFF00E5FF);

    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: crystalBlue, width: 1.5),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 32),
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                "Welcome Back",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),

              const SizedBox(height: 4),

              Selector<TripProvider, DriverModel?>(
                selector: (context, provider) => provider.driver,
                builder: (context, driver, child) {
                  return Text(
                    driver?.userName ?? "Loading...",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
             
            ],
          ),
        ),

        Selector<TripProvider, String>(
          selector: (context, provider) => provider.connectionStatus,
          builder: (context, connectionStatus, child) {
            //  الـ Container الكبير يأتي بداخل الـ builder ويرسم حدوده بناءً على المتغير الصافي!
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .05),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  // الحدود تتغير تلقائياً بالملي ثانية دون تكرار!
                  color:
                      (connectionStatus == "ONLINE"
                              ? Colors.greenAccent
                              : Colors.redAccent)
                          .withValues(alpha: .4),
                ),
              ),
              child: Row(
                children: [
                  // اللمبة الصغيرة تقرأ نفس المتغير حياً داخل الميموري
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: connectionStatus == "ONLINE"
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // النص يطبع الحالة واللون المتناسق بنقاء 100% وبصفر أخطاء
                  Text(
                    connectionStatus,
                    style: TextStyle(
                      color: connectionStatus == "ONLINE"
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
