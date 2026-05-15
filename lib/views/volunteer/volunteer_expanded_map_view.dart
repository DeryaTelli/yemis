import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/volunteer/shelter_model.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart';
import '../../utils/theme/app_theme.dart';
import '../../widgets/volunteer/volunteer_listing_card.dart';

class VolunteerExpandedMapView extends StatefulWidget {
  final List<VolunteerListing> listings;
  final List<ShelterModel> shelters;

  const VolunteerExpandedMapView({
    super.key,
    required this.listings,
    this.shelters = const [],
  });

  @override
  State<VolunteerExpandedMapView> createState() => _VolunteerExpandedMapViewState();
}

class _VolunteerExpandedMapViewState extends State<VolunteerExpandedMapView> {
  VolunteerListing? _selectedListing;
  ShelterModel? _selectedShelter;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeFor(AppSection.volunteer),
      child: Scaffold(
        body: Stack(
          children: [
          // ── Harita Alanı ────────────────────────────
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
                              _selectedShelter = null;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.red : AppColors.volunteerColor,
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
                                isSelected ? Icons.location_on : Icons.volunteer_activism,
                                color: Colors.white,
                                size: isSelected ? 20 : 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ...widget.shelters.map(
                    (shelter) {
                      final isSelected = _selectedShelter?.id == shelter.id;
                      return Marker(
                        point: LatLng(shelter.latitude, shelter.longitude),
                        width: isSelected ? 40 : 32,
                        height: isSelected ? 40 : 32,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedShelter = shelter;
                              _selectedListing = null;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.orange.shade800 : Colors.orange,
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
                                Icons.pets,
                                color: Colors.white,
                                size: isSelected ? 20 : 14,
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
                  VolunteerListingCard(
                    listing: _selectedListing!,
                    width: double.infinity,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.volunteerDetail,
                      arguments: _selectedListing,
                    ),
                  ),
                ],
              ),
            ),

          // ── Seçili Barınak Kartı (Alt Panel) ──────────────
          if (_selectedShelter != null)
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
                      onPressed: () => setState(() => _selectedShelter = null),
                    ),
                  ),
                  // Barınak Bilgi Kartı
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.pets, color: Colors.orange),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedShelter!.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_selectedShelter!.district}, ${_selectedShelter!.city}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              if (_selectedShelter!.phoneNumber != null)
                                Text(
                                  _selectedShelter!.phoneNumber!,
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}
}
