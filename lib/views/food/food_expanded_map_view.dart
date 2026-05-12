import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/food/food_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../widgets/food/food_listing_card.dart';

class FoodExpandedMapView extends StatefulWidget {
  final List<FoodListing> listings;

  const FoodExpandedMapView({super.key, required this.listings});

  @override
  State<FoodExpandedMapView> createState() => _FoodExpandedMapViewState();
}

class _FoodExpandedMapViewState extends State<FoodExpandedMapView> {
  FoodListing? _selectedListing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: widget.listings.isNotEmpty && widget.listings.first.latitude != null
                  ? LatLng(widget.listings.first.latitude!, widget.listings.first.longitude!)
                  : const LatLng(41.1993, 32.6247),
              initialZoom: 16.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yemis.app',
              ),
              MarkerLayer(
                markers: [
                  ...widget.listings.where((l) => l.latitude != null).map(
                    (listing) {
                      final isSelected = _selectedListing?.id == listing.id;
                      return Marker(
                        point: LatLng(listing.latitude!, listing.longitude!),
                        width: isSelected ? 40 : 32,
                        height: isSelected ? 40 : 32,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedListing = listing;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.red : AppColors.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: isSelected ? 3 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: isSelected ? 8 : 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                isSelected ? Icons.location_on : Icons.restaurant,
                                color: Colors.white,
                                size: isSelected ? 20 : 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // ── Üst Bar (Geri Butonu) ────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: FloatingActionButton.small(
              backgroundColor: Colors.white,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),

          // ── Seçili İlan Kartı (Alt Panel) ──────────────
          if (_selectedListing != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Kapat butonu
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.grey),
                      onPressed: () => setState(() => _selectedListing = null),
                    ),
                  ),
                  // Kart
                  FoodListingCard(
                    listing: _selectedListing!,
                    width: double.infinity,
                    onFavoriteTap: () {},
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/food-detail',
                      arguments: _selectedListing,
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
