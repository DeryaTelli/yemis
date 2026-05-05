import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../utils/constants/app_colors.dart';

/// Harita üzerinde ilanları gösteren bileşen.
class SearchMapView extends StatelessWidget {
  final List<dynamic> listings; // FoodListing veya VolunteerListing
  final Color accentColor;
  final void Function(dynamic) onMarkerTap;
  final LatLng? initialCenter;

  const SearchMapView({
    super.key,
    required this.listings,
    required this.accentColor,
    required this.onMarkerTap,
    this.initialCenter,
  });

  @override
  Widget build(BuildContext context) {
    // Tüm ilanların ortalamasını alarak haritayı konumlandır (veya default bi yer seç)
    final LatLng center = initialCenter ?? const LatLng(41.2048, 32.6218); // Karabük Merkez focus
    
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.yemis.app',
        ),
        MarkerLayer(
          markers: listings.where((l) => l.latitude != null && l.longitude != null).map((listing) {
            return Marker(
              point: LatLng(listing.latitude!, listing.longitude!),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => onMarkerTap(listing),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: accentColor,
                    size: 24,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
