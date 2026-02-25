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
            initialZoom: 13.0,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                  width: 30,
                  height: 30,
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primaryColor,
                    size: 30,
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
