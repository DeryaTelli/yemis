import 'package:flutter/material.dart';
import '../../models/food/food_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../widgets/food/food_listing_card.dart';
import '../../widgets/food/food_map_section.dart';

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
          // ── Harita Alanı ────────────────────────────
          Hero(
            tag: 'food_map',
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(500),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Arka Plan (FoodMapSection içindeki painter'ı kullanıyoruz)
                  Container(
                    color: const Color(0xFFF2F2F2),
                    child: CustomPaint(painter: RealisticMapPainter()),
                  ),
                  
                  // Pinler
                  const Center(child: MapPinTeardrop(isCenter: true)),

                  ..._getMockPositions(widget.listings.length).asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final pos = entry.value;
                      final listing = widget.listings[index];
                      
                      return Positioned(
                        left: pos.dx,
                        top: pos.dy,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedListing = listing;
                            });
                          },
                          child: const MapPinTeardrop(isCenter: false),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
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

  List<Offset> _getMockPositions(int count) {
    const basePositions = [
      Offset(100, 150),
      Offset(300, 200),
      Offset(400, 450),
      Offset(150, 500),
      Offset(500, 300),
    ];
    return basePositions.take(count).toList();
  }
}
