import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../viewmodels/volunteer/volunteer_detail_viewmodel.dart';
import '../../views/location/navigation_view.dart';
import '../food/order_location_map.dart';

/// Volunteer Detay → Sipariş sekmesi içeriği.
/// Food detail'deki FoodOrderTab ile aynı yapı; volunteer renk temasıyla.
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
          // ── Gönüllü Bilgilendirmesi ────────────────────────
          Text(
            LocaleKeys.volunteerOrderTab_detailTitle.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            LocaleKeys.volunteerOrderTab_detailSubtitle.tr(),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.hintTextColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // ── İlan Açıklaması Başlığı ───────────────────────
          Text(
            LocaleKeys.volunteerOrderTab_descriptionTitle.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),

          // ── Açıklama ──────────────────────────────────────
          if (listing.description != null)
            Text(
              listing.description!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.hintTextColor,
                height: 1.5,
              ),
            ),
          const SizedBox(height: 16),

          // ── Harita: İlan Lokasyonu ─────────────────────────
          if (vm.listingLatLng != null)
            OrderLocationMap(
              businessLocation: vm.listingLatLng!,
              userLocation: vm.userLatLng,
              height: 180,
              accentColor: AppColors.volunteerColor,
              markerIcon: Icons.volunteer_activism,
            )
          else
            SizedBox(
              height: 180,
              child: Center(
                child: Text(LocaleKeys.volunteerDetail_noLocation.tr()),
              ),
            ),
          const SizedBox(height: 12),

          // ── Lokasyona Git Butonu ───────────────────────────
          _GoToButton(
            label: LocaleKeys.volunteerDetail_goToLocation.tr(),
            onTap: () => _push(
              context,
              lat: vm.listingLatLng?.latitude ?? 41.0082,
              lng: vm.listingLatLng?.longitude ?? 28.9784,
              name: listing.title,
              address: listing.location,
            ),
          ),
          const SizedBox(height: 24),

          // ── En Yakın Barınak başlığı ───────────────────────
          Text(
            LocaleKeys.volunteerDetail_nearestShelter.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),

          // ── Barınak Alanı (Loading / Shelter / Not Found) ──
          if (vm.isShelterLoading)
            const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator(color: AppColors.volunteerColor)),
            )
          else if (vm.nearestShelter == null)
            Center(
              child: Column(
                children: [
                  Lottie.asset(
                    'assets/lottie/notFound.json',
                    height: 140,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    LocaleKeys.volunteerOrderTab_noShelterNearby.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.hintTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Harita: Barınak Lokasyonu
            if (vm.shelterLatLng != null)
              OrderLocationMap(
                businessLocation: vm.shelterLatLng!,
                userLocation: vm.userLatLng,
                height: 180,
                accentColor: AppColors.volunteerColor,
                markerIcon: Icons.pets, // Hayvan barınağı için pati ikonu
              ),
            const SizedBox(height: 12),

            // Barınak Bilgisi ve Mesafe
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vm.shelterName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      Text(
                        vm.shelterAddress,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.hintTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.volunteerColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    vm.distanceToShelterText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.volunteerColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Barınağa Git Butonu
            _GoToButton(
              label: LocaleKeys.volunteerDetail_goToShelter.tr(),
              onTap: () => _push(
                context,
                lat: vm.shelterLatLng!.latitude,
                lng: vm.shelterLatLng!.longitude,
                name: vm.shelterName,
                address: vm.shelterAddress,
              ),
            ),
          ],
          const SizedBox(height: 24),

          // ── Daha Fazla Detay (Expandable) ─────────────────
          _ExpandableDetail(vm: vm, listing: listing),
        ],
      ),
    );
  }

  void _push(
    BuildContext context, {
    required double lat,
    required double lng,
    required String name,
    required String address,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NavigationView(
          latitude: lat,
          longitude: lng,
          businessName: name,
          address: address,
          accentGradient: AppColors.volunteerBackgroundGradient,
          accentColor: AppColors.volunteerColor,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Lokasyona / Barınağa Git Butonu
// ─────────────────────────────────────────────────────
class _GoToButton extends StatelessWidget {
  const _GoToButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          gradient: AppColors.volunteerBackgroundGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Genişleyen Detay Bölümü
// ─────────────────────────────────────────────────────
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
          ),
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
                  Text(
                    LocaleKeys.volunteerDetail_moreDetail.tr(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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
                  Text(
                    LocaleKeys.volunteerDetail_ingredients.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${LocaleKeys.volunteerOrderTab_ingredientsText.tr()}${listing.ingredients != null ? '\n\n${listing.ingredients}' : ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.hintTextColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    LocaleKeys.volunteerDetail_packaging.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${LocaleKeys.volunteerOrderTab_packagingText.tr()}${listing.packageInfo != null ? '\n\n${listing.packageInfo}' : ''}',
                    style: const TextStyle(
                      fontSize: 13,
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
