import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AnimatedTruckMarker extends StatelessWidget {
  final LatLng position;

  const AnimatedTruckMarker({
    super.key,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [
        Marker(
          point: position,
          width: 60,
          height: 60,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.85, end: 1),
            curve: Curves.easeOut,

            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },

            child: const Icon(
              Icons.local_shipping,
              color: Colors.red,
              size: 42,
            ),
          ),
        ),
      ],
    );
  }
}