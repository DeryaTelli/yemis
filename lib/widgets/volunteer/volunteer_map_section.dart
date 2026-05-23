import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/volunteer/shelter_model.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../views/volunteer/volunteer_expanded_map_view.dart';
import '../common/app_tile_layer.dart';

/// Gönüllü harita alanını gösterir.
class VolunteerMapSection extends StatefulWidget {
  const VolunteerMapSection({
    super.key,
    this.listings = const [],
    this.shelters = const [],
    this.userLat,
    this.userLng,
  });

  final List<VolunteerListing> listings;
  final List<ShelterModel> shelters;
  final double? userLat;
  final double? userLng;

  @override
  State<VolunteerMapSection> createState() => _VolunteerMapSectionState();
}

class _VolunteerMapSectionState extends State<VolunteerMapSection> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(VolunteerMapSection oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    return Container(
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
        child: Stack(
          fit: StackFit.expand,
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
                const AppTileLayer(),
                MarkerLayer(
                  markers: [
                    ...widget.listings
                        .where((l) => l.latitude != null)
                        .map(
                          (l) => Marker(
                            point: LatLng(l.latitude!, l.longitude!),
                            width: 32,
                            height: 32,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.volunteerColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.volunteer_activism,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ...widget.shelters.map(
                      (s) => Marker(
                        point: LatLng(s.latitude, s.longitude),
                        width: 32,
                        height: 32,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.pets,
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

            // ── Genişlet Butonu (sağ alt) ─────────
            Positioned(
              right: 12,
              bottom: 12,
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VolunteerExpandedMapView(
                      listings: widget.listings,
                      shelters: widget.shelters,
                    ),
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
                    color: AppColors.volunteerColor,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
