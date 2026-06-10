import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/location/map_navigation_service.dart';
import '../../services/location/routing_service.dart';
import '../../utils/constants/app_colors.dart';
import '../common/app_tile_layer.dart';

class OrderLocationMap extends StatefulWidget {
  const OrderLocationMap({
    super.key,
    required this.businessLocation,
    this.userLocation,
    this.height = 150,
    this.accentColor,
    this.markerIcon,
    this.onTap,
  });

  final LatLng businessLocation;
  final LatLng? userLocation;
  final double height;
  final Color? accentColor;
  final IconData? markerIcon;
  final VoidCallback? onTap;

  @override
  State<OrderLocationMap> createState() => _OrderLocationMapState();
}

class _OrderLocationMapState extends State<OrderLocationMap> {
  final MapController _mapController = MapController();
  final RoutingService _routingService = RoutingService();
  List<LatLng> _routePoints = const [];

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  @override
  void didUpdateWidget(covariant OrderLocationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userLocation != widget.userLocation ||
        oldWidget.businessLocation != widget.businessLocation) {
      _loadRoute();
    }
  }

  Future<void> _loadRoute() async {
    if (widget.userLocation == null) {
      if (mounted) setState(() => _routePoints = const []);
      return;
    }

    try {
      final route = await _routingService.getRoute(
        origin: widget.userLocation!,
        destination: widget.businessLocation,
        travelMode: NavigationTravelMode.driving,
      );
      if (!mounted) return;
      setState(() => _routePoints = route.points);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _routePoints.isEmpty) return;
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(_routePoints),
            padding: const EdgeInsets.all(24),
          ),
        );
      });
    } catch (_) {
      if (mounted) setState(() => _routePoints = const []);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapContent = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.businessLocation,
            initialZoom: 15.5,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            const AppTileLayer(vivid: true),
            if (_routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline<Object>(
                    points: _routePoints,
                    color: Colors.white.withValues(alpha: 0.95),
                    strokeWidth: 8,
                  ),
                  Polyline<Object>(
                    points: _routePoints,
                    color: widget.accentColor ?? AppColors.primaryColor,
                    strokeWidth: 4,
                    pattern: StrokePattern.dashed(segments: const [12, 8]),
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                if (widget.userLocation != null)
                  Marker(
                    point: widget.userLocation!,
                    width: 30,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.navigation_rounded,
                        color: widget.accentColor ?? AppColors.primaryColor,
                        size: 30,
                      ),
                    ),
                  ),
                Marker(
                  point: widget.businessLocation,
                  width: 32,
                  height: 32,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.accentColor ?? AppColors.primaryColor,
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
                    child: Center(
                      child: Icon(
                        widget.markerIcon ?? Icons.restaurant,
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

    if (widget.onTap == null) {
      return mapContent;
    }

    return GestureDetector(onTap: widget.onTap, child: mapContent);
  }
}
