import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../utils/constants/app_colors.dart';

class OrderLocationMap extends StatelessWidget {
  const OrderLocationMap({
    super.key,
    required this.businessLocation,
    this.userLocation,
    this.height = 150,
  });

  final LatLng businessLocation;
  final LatLng? userLocation;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: businessLocation,
            initialZoom: 15.5,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.deryatelli.yemis',
            ),
            if (userLocation != null)
              PolylineLayer(
                polylines: [
                  Polyline<Object>(
                    points: [userLocation!, businessLocation],
                    color: AppColors.primaryColor.withValues(alpha: 0.5),
                    strokeWidth: 3,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                if (userLocation != null)
                  Marker(
                    point: userLocation!,
                    width: 30,
                    height: 30,
                    child: const Icon(
                      Icons.person_pin_circle_rounded,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                Marker(
                  point: businessLocation,
                  width: 32,
                  height: 32,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
