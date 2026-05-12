import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/food/food_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../views/food/food_expanded_map_view.dart';

/// Harita alanını gösterir.
/// Fotoğraftaki gibi gerçekçi bir harita görünümü sunar.
class FoodMapSection extends StatefulWidget {
  const FoodMapSection({
    super.key,
    this.listings = const [],
    this.userLat,
    this.userLng,
  });

  final List<FoodListing> listings;
  final double? userLat;
  final double? userLng;

  @override
  State<FoodMapSection> createState() => _FoodMapSectionState();
}

class _FoodMapSectionState extends State<FoodMapSection> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(FoodMapSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // İlanlar geldiğinde haritayı ilk ilana odakla
    if (widget.listings.isNotEmpty && oldWidget.listings.isEmpty) {
      final first = widget.listings.first;
      if (first.latitude != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(LatLng(first.latitude!, first.longitude!), 15.0);
        });
      }
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FoodExpandedMapView(listings: widget.listings),
        ),
      ),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Hero(
            tag: 'food_map',
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: widget.listings.isNotEmpty &&
                            widget.listings.first.latitude != null
                        ? LatLng(
                            widget.listings.first.latitude!,
                            widget.listings.first.longitude!,
                          )
                        : (widget.userLat != null && widget.userLng != null)
                            ? LatLng(widget.userLat!, widget.userLng!)
                            : const LatLng(41.1993, 32.6247),
                    initialZoom: 15.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.yemis.app',
                    ),
                    MarkerLayer(
                      markers: [
                        ...widget.listings
                            .where((l) => l.latitude != null)
                            .map(
                              (l) => Marker(
                                point: LatLng(l.latitude!, l.longitude!),
                                width: 36,
                                height: 36,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
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
                            ),
                      ],
                    ),
                  ],
                ),
                // ── Genişlet Butonu (sağ alt) ───────────
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FoodExpandedMapView(listings: widget.listings),
                      ),
                    ),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.fullscreen_rounded,
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
