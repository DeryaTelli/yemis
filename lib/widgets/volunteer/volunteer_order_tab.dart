import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/volunteer/volunteer_detail_viewmodel.dart';
import '../../views/location/navigation_view.dart';
import '../food/order_location_map.dart';

class VolunteerOrderTab extends StatelessWidget {
  const VolunteerOrderTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VolunteerDetailViewModel>();
    final listing = vm.listing;
    if (listing == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gönüllü Kutu Detayı Başlığı ──────────
          const Text(
            "Gönüllü Kutu Detayı",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),

          // ── Açıklama ──────────────────────────
          if (listing.description != null)
            Text(
              listing.description!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.hintTextColor,
                height: 1.5,
              ),
            ),
          const SizedBox(height: 16),

          // ── Harita: İlan Lokasyonu ────
          if (vm.listingLatLng != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: OrderLocationMap(
                businessLocation: vm.listingLatLng!,
                userLocation: vm.userLatLng,
                height: 100,
              ),
            ),
            const SizedBox(height: 8),
            _ActionButton(
              label: "Lokasyona Git",
              onTap: () => _navigateTo(context, vm.listingLatLng!.latitude, vm.listingLatLng!.longitude, "İlan Lokasyonu", listing.location),
            ),
            const SizedBox(height: 20),
          ],

          // ── Harita: Barınak Lokasyonu ─────
          const Text(
            "En Yakın Barınak",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          if (vm.shelterLatLng != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: OrderLocationMap(
                businessLocation: vm.shelterLatLng!,
                userLocation: vm.userLatLng,
                height: 100,
              ),
            ),
            const SizedBox(height: 8),
            _ActionButton(
              label: "Barınağa Git",
              onTap: () => _navigateTo(context, vm.shelterLatLng!.latitude, vm.shelterLatLng!.longitude, "En Yakın Barınak", "Barınak Lokasyonu"),
            ),
          ] else ...[
            const SizedBox(
              height: 100,
              child: Center(child: Text("Barınak lokasyon bilgisi yok")),
            ),
            const SizedBox(height: 8),
            _ActionButton(
              label: "Barınağa Git",
              onTap: () {},
            ),
          ],
          const SizedBox(height: 20),

          // ── Daha Fazla Detay (Expandable) ────────────
          _ExpandableDetail(vm: vm, listing: listing),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, double lat, double lng, String name, String address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NavigationView(
          latitude: lat,
          longitude: lng,
          businessName: name,
          address: address,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap});
  
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF27AE60), // Hardcoded matching green from design for buttons
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _ExpandableDetail extends StatelessWidget {
  const _ExpandableDetail({required this.vm, required this.listing});

  final VolunteerDetailViewModel vm;
  final VolunteerListing listing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık satırı
          GestureDetector(
            onTap: vm.toggleDetailExpanded,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Daha Fazla Detay",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  AnimatedRotation(
                    turns: vm.isDetailExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.volunteerColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // İçerik (genişlediğinde görünür)
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 12),
                  const Text(
                    "İçerikler & Alerjenler",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (listing.ingredients != null)
                    Text(
                      listing.ingredients!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.hintTextColor,
                        height: 1.5,
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    "Paket",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (listing.packageInfo != null)
                    Text(
                      listing.packageInfo!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.hintTextColor,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
            crossFadeState: vm.isDetailExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
