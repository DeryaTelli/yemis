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
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Kategori Detayı ──────────────────────────────
          Text(
            LocaleKeys.foodOrderTab_categoryDetail.tr(
              namedArgs: {'category': listing.category.toLowerCase() == 'patiseri'
                ? LocaleKeys.foodOrderTab_categoryBreadPastry.tr()
                : listing.category.substring(0, 1).toUpperCase() + listing.category.substring(1)},
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            listing.category == 'Sürpriz Kutu'
                ? LocaleKeys.foodOrderTab_surpriseBoxDesc.tr()
                : LocaleKeys.foodOrderTab_categoryDesc.tr(
                    namedArgs: {'category': listing.category.toLowerCase()},
                  ),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.hintTextColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // ── İlan Detayı (Varsa) ──────────────────────────
          if (listing.description != null && listing.description!.isNotEmpty) ...[
            Text(
              LocaleKeys.foodOrderTab_listingDetail.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              listing.description!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.hintTextColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Mesafe Bilgisi ──────────────────────────────
          if (vm.businessLatLng != null && vm.userLatLng != null) ...[
            Row(
              children: [
                const Icon(Icons.directions_walk_rounded, size: 18, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Text(
                  LocaleKeys.foodOrderTab_distanceText.tr(namedArgs: {'distance': vm.distanceText ?? ''}),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // ── Harita ──────────────────────────────────
          if (vm.businessLatLng != null)
            OrderLocationMap(
              businessLocation: vm.businessLatLng!,
              userLocation: vm.userLatLng,
              height: 180,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NavigationView(
                      latitude: listing.latitude ?? 41.0082,
                      longitude: listing.longitude ?? 28.9784,
                      businessName: listing.shopName,
                      address: listing.fullAddress ?? listing.location,
                    ),
                  ),
                );
              },
            )
          else
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_off_rounded, color: Colors.grey.shade400, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      LocaleKeys.foodDetail_noLocation.tr(),
                      style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

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
              address: listing.fullAddress ?? listing.location,
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
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.grid_view_rounded, LocaleKeys.foodOrderTab_category.tr(), listing.category),
                  const SizedBox(height: 12),
                  Text(
                    LocaleKeys.foodOrderTab_ingredientsAllergens.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    LocaleKeys.foodOrderTab_surpriseIngredients.tr(),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.hintTextColor,
                      height: 1.5,
                    ),
                  ),
                  if (listing.allergens != null && listing.allergens!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade100),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              LocaleKeys.foodOrderTab_allergens.tr(namedArgs: {'allergens': listing.allergens ?? ''}),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.primaryTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            crossFadeState: vm.isDetailExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryTextColor,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          listing.category.toLowerCase() == 'patiseri'
              ? LocaleKeys.foodOrderTab_categoryBreadPastry.tr()
              : value.substring(0, 1).toUpperCase() + value.substring(1),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.hintTextColor,
          ),
        ),
      ],
    );
  }
}
