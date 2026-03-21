import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food/food_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../viewmodels/food/food_detail_viewmodel.dart';
import '../../views/location/navigation_view.dart';
import 'order_location_map.dart';

/// Food Detay → Sipariş sekmesi içeriği.
class FoodOrderTab extends StatelessWidget {
  const FoodOrderTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FoodDetailViewModel>();
    final listing = vm.listing;
    if (listing == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ürün Başlığı ──────────────────────────────
          Text(
            listing.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),

          // ── Açıklama ──────────────────────────────────
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

          // ── Harita ──────────────────────────────────
          if (vm.businessLatLng != null)
            OrderLocationMap(
              businessLocation: vm.businessLatLng!,
              userLocation: vm.userLatLng,
              height: 180,
            )
          else
            SizedBox(
              height: 180,
              child: Center(child: Text(LocaleKeys.foodDetail_noLocation.tr())),
            ),
          const SizedBox(height: 12),

          // ── Lokasyona Git Butonu ───────────────────────
          _GoToLocationButton(listing: listing),
          const SizedBox(height: 20),

          // ── Daha Fazla Detay (Expandable) ─────────────
          _ExpandableDetail(vm: vm, listing: listing),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Lokasyona Git Butonu
// ─────────────────────────────────────────────────────
class _GoToLocationButton extends StatelessWidget {
  const _GoToLocationButton({required this.listing});

  final FoodListing listing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NavigationView(
              latitude: listing.latitude ?? 41.0082,
              longitude: listing.longitude ?? 28.9784,
              businessName: listing.shopName,
              address: listing.location,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          gradient: AppColors.primaryButtonGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          LocaleKeys.foodDetail_goToLocation.tr(),
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

  final FoodDetailViewModel vm;
  final FoodListing listing;

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
                  Text(
                    LocaleKeys.foodDetail_moreDetail.tr(),
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
                      color: AppColors.primaryColor,
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
                    LocaleKeys.foodDetail_ingredients.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (listing.ingredients != null)
                    Text(
                      listing.ingredients!,
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
