import 'package:flutter/material.dart';

class AssignTruckDialog extends StatefulWidget {
  final String driverName;
  final Future<void> Function(String truckId) onAssign;

  const AssignTruckDialog({
    super.key,
    required this.driverName,
    required this.onAssign,
  });

  @override
  State<AssignTruckDialog> createState() => _AssignTruckDialogState();
}

class _AssignTruckDialogState extends State<AssignTruckDialog> {
  late final TextEditingController _truckController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _truckController = TextEditingController();
  }

  @override
  void dispose() {
    _truckController.dispose();
    super.dispose();
  }

  Future<void> _assignTruck() async {
    final truckId = _truckController.text.trim();

    if (truckId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Truck ID"),
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onAssign(truckId);

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to assign truck: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xff182233),

      title: const Text(
        "Assign Truck",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Enter the Truck ID assigned to ${widget.driverName}",
              style: const TextStyle(
                color: Colors.white60,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _truckController,
              enabled: !_isLoading,
              autofocus: true,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: "Truck ID",
                hintStyle: const TextStyle(
                  color: Colors.white38,
                ),
                filled: true,
                fillColor: const Color(0xff0B1220),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text(
            "Cancel",
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ),

        ElevatedButton(
          onPressed: _isLoading ? null : _assignTruck,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            foregroundColor: Colors.black,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text("Assign & Accept"),
        ),
      ],
    );
  }
}