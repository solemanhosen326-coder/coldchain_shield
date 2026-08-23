import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enterprise_provider.dart';
import '../truck_provider.dart';
import '../widgets/truck/truck_card.dart';

class TruckManagementPage extends StatefulWidget {
  const TruckManagementPage({super.key});

  @override
  State<TruckManagementPage> createState() => _TruckManagementPageState();
}

class _TruckManagementPageState extends State<TruckManagementPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final enterprise =
          context.read<EnterpriseProvider>().enterprise;

      if (enterprise != null) {
        context
            .read<TruckProvider>()
            .startListening(enterprise.companyId);
      }
    });
  }

  @override
  void dispose() {
    context.read<TruckProvider>().stopListening();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B1220),

      appBar: AppBar(
        title: const Text("Truck Management"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          
        },
        child: const Icon(Icons.add),
      ),

      body: Consumer<TruckProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.trucks.isEmpty) {
            return const Center(
              child: Text(
                "No Trucks",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: provider.trucks.length,
            itemBuilder: (_, index) {
              return TruckCard(
                truck: provider.trucks[index],
              );
            },
          );
        },
      ),
    );
  }
}