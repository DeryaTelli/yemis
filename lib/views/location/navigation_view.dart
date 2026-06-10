import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../utils/locale_keys.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/location/navigation_viewmodel.dart';
import '../../services/location/map_navigation_service.dart';
import '../../widgets/common/app_tile_layer.dart';

class NavigationView extends StatelessWidget {
  const NavigationView({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.businessName,
    required this.address,
    this.accentGradient,
    this.accentColor,
  });

  final double latitude;
  final double longitude;
  final String businessName;
  final String address;

  /// Buton ve vurgu gradientı — null ise primaryButtonGradient kullanılır.
  final LinearGradient? accentGradient;

  /// İkon ve badge rengi — null ise primaryColor kullanılır.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = NavigationViewModel(
          destinationLat: latitude,
          destinationLng: longitude,
          businessName: businessName,
          address: address,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) => vm.init());
        return vm;
      },
      child: _NavigationBody(
        accentGradient: accentGradient,
        accentColor: accentColor,
      ),
    );
  }
}

class _NavigationBody extends StatelessWidget {
  const _NavigationBody({this.accentGradient, this.accentColor});

  final LinearGradient? accentGradient;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NavigationViewModel>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: accentColor ?? AppColors.primaryColor,
              size: 18,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // ── Map ────────────────────────────────────
          Positioned.fill(
            child: vm.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: accentColor ?? AppColors.primaryColor,
                    ),
                  )
                : _buildMap(vm),
          ),

          // ── Error Message / Permission ─────────────
          if (!vm.isLoading && !vm.hasPermission) _buildPermissionWarning(vm),

          // ── Bottom Information Card ────────────────
          if (!vm.isLoading)
            Positioned(
              left: 16,
              right: 16,
              bottom: 32,
              child: _buildInfoCard(context, vm),
            ),
        ],
      ),
    );
  }

  Widget _buildMap(NavigationViewModel vm) {
    return FlutterMap(
      mapController: vm.mapController,
      options: MapOptions(
        initialCenter: vm.userLocation ?? vm.destination,
        initialZoom: 14.0,
      ),
      children: [
        const AppTileLayer(vivid: true),
        if (vm.hasRoute)
          PolylineLayer(
            polylines: [
              Polyline(
                points: vm.routePoints,
                color: Colors.white.withValues(alpha: 0.95),
                strokeWidth: 10,
              ),
              Polyline(
                points: vm.routePoints,
                color: accentColor ?? AppColors.primaryColor,
                strokeWidth: 6,
                pattern: StrokePattern.dashed(segments: const [14, 10]),
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            // User Marker
            if (vm.userLocation != null)
              Marker(
                point: vm.userLocation!,
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Transform.rotate(
                    angle: vm.isNavigating && vm.currentPosition != null
                        ? vm.currentPosition!.heading * 3.1415926535 / 180
                        : 0,
                    child: Icon(
                      vm.isNavigating
                          ? Icons.navigation_rounded
                          : Icons.person_pin_circle_rounded,
                      color: accentColor ?? AppColors.primaryColor,
                      size: 40,
                    ),
                  ),
                ),
              ),
            // Business Marker
            Marker(
              point: vm.destination,
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: accentColor ?? AppColors.primaryColor,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPermissionWarning(NavigationViewModel vm) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(20),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              vm.errorMessage ?? LocaleKeys.navigation_permissionRequired.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: vm.openSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(LocaleKeys.navigation_openSettings.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, NavigationViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vm.businessName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vm.address,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.hintTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (accentColor ?? AppColors.primaryColor).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      vm.distanceText,
                      style: TextStyle(
                        color: accentColor ?? AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (vm.hasRoute)
                      Text(
                        vm.durationText,
                        style: TextStyle(
                          color: accentColor ?? AppColors.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTravelModeSelector(vm),
          const SizedBox(height: 20),
          _buildActionButton(
            title: vm.isRouteLoading
                ? LocaleKeys.navigation_calculatingRoute.tr()
                : LocaleKeys.navigation_goToLocation.tr(),
            onTap: vm.isRouteLoading ? () {} : vm.startGuidance,
            isGradient: true,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            title: LocaleKeys.navigation_navigate.tr(),
            onTap: () => _showNavigationOptions(context, vm),
            isGradient: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTravelModeSelector(NavigationViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: _buildTravelModeButton(
            icon: Icons.directions_car_filled_rounded,
            label: LocaleKeys.navigation_driving.tr(),
            selected: vm.travelMode == NavigationTravelMode.driving,
            onTap: () => vm.selectTravelMode(NavigationTravelMode.driving),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTravelModeButton(
            icon: Icons.directions_walk_rounded,
            label: LocaleKeys.navigation_walking.tr(),
            selected: vm.travelMode == NavigationTravelMode.walking,
            onTap: () => vm.selectTravelMode(NavigationTravelMode.walking),
          ),
        ),
      ],
    );
  }

  Widget _buildTravelModeButton({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final color = accentColor ?? AppColors.primaryColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? color : Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? color : Colors.grey[600], size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? color : Colors.grey[700],
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required VoidCallback onTap,
    bool isGradient = false,
  }) {
    final gradient = accentGradient ?? AppColors.primaryButtonGradient;
    final color = accentColor ?? AppColors.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          gradient: isGradient ? gradient : null,
          color: isGradient ? null : color,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _showNavigationOptions(BuildContext context, NavigationViewModel vm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LocaleKeys.navigation_getDirections.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildMapOption(
              icon: Icons.map_outlined,
              title: LocaleKeys.navigation_openGoogleMaps.tr(),
              onTap: () {
                Navigator.pop(context);
                vm.startNavigation(vm.travelMode);
              },
            ),
            _buildMapOption(
              icon: Icons.navigation_outlined,
              title: LocaleKeys.navigation_openYandexMaps.tr(),
              onTap: () {
                Navigator.pop(context);
                vm.launchYandexMaps();
              },
            ),
            if (Theme.of(context).platform == TargetPlatform.iOS)
              _buildMapOption(
                icon: Icons.apple,
                title: LocaleKeys.navigation_openAppleMaps.tr(),
                onTap: () {
                  Navigator.pop(context);
                  vm.launchAppleMaps();
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMapOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[100],
        child: Icon(icon, color: accentColor ?? AppColors.primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
