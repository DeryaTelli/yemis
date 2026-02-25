import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/location/navigation_viewmodel.dart';

class NavigationView extends StatelessWidget {
  const NavigationView({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.businessName,
    required this.address,
  });

  final double latitude;
  final double longitude;
  final String businessName;
  final String address;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationViewModel(
        destinationLat: latitude,
        destinationLng: longitude,
        businessName: businessName,
        address: address,
      )..init(),
      child: const _NavigationBody(),
    );
  }
}

class _NavigationBody extends StatelessWidget {
  const _NavigationBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NavigationViewModel>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.primaryTextColor,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── Map ────────────────────────────────────
          Positioned.fill(
            child: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
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
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.deryatelli.yemis',
        ),
        if (vm.userLocation != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: [vm.userLocation!, vm.destination],
                color: AppColors.primaryColor.withOpacity(0.7),
                strokeWidth: 4,
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
                child: const Icon(
                  Icons.person_pin_circle_rounded,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
            // Business Marker
            Marker(
              point: vm.destination,
              width: 40,
              height: 40,
              child: const Icon(
                Icons.location_on_rounded,
                color: AppColors.primaryColor,
                size: 40,
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
              color: Colors.black.withOpacity(0.1),
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
              vm.errorMessage ?? "Konum izni gerekiyor",
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
              child: const Text("Ayarları Aç"),
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
            color: Colors.black.withOpacity(0.1),
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
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  vm.distanceText,
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            title: "Konuma Git",
            onTap: vm.moveToDestination,
            isGradient: true,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            title: "Yönlendir",
            onTap: () => _showNavigationOptions(context, vm),
            isGradient: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required VoidCallback onTap,
    bool isGradient = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          gradient: isGradient ? AppColors.primaryButtonGradient : null,
          color: isGradient ? null : AppColors.primaryColor,
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
            const Text(
              "Yol Tarifi Al",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildMapOption(
              icon: Icons.map_outlined,
              title: "Google Maps ile Aç",
              onTap: () {
                Navigator.pop(context);
                vm.launchGoogleMaps();
              },
            ),
            _buildMapOption(
              icon: Icons.navigation_outlined,
              title: "Yandex Navigasyon ile Aç",
              onTap: () {
                Navigator.pop(context);
                vm.launchYandexMaps();
              },
            ),
            if (Theme.of(context).platform == TargetPlatform.iOS)
              _buildMapOption(
                icon: Icons.apple,
                title: "Apple Maps ile Aç",
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
        child: Icon(icon, color: AppColors.primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
