import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:yemis/utils/locale_keys.dart';
import '../../models/food/food_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart';
import '../../views/location/navigation_view.dart';
import '../../widgets/food/order_location_map.dart';

/// Rezervasyon onay ekranı.
///
/// Gösterir: restoran adı + mesafe, harita, "Lokasyona Git" butonu,
/// rezervasyon kartı (ürün bilgisi, saat, fiyat, "İptal Et").
/// "Geri" tıklanınca foodHome ana sayfasına döner.
class FoodReservationConfirmView extends StatelessWidget {
  const FoodReservationConfirmView({
    super.key,
    required this.listing,
    required this.quantity,
    required this.totalPrice,
  });

  final FoodListing listing;
  final int quantity;
  final double totalPrice;

  @override
  Widget build(BuildContext context) {
    final LatLng? businessLatLng =
        listing.latitude != null && listing.longitude != null
        ? LatLng(listing.latitude!, listing.longitude!)
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(LocaleKeys.foodReservationConfirm_title.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Restoran Başlığı ────────────────────────────
            _RestaurantHeader(listing: listing),
            const SizedBox(height: 16),

            // ── Harita ─────────────────────────────────────
            if (businessLatLng != null)
              OrderLocationMap(
                businessLocation: businessLatLng,
                height: 160,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => NavigationView(
                        latitude: businessLatLng.latitude,
                        longitude: businessLatLng.longitude,
                        businessName: listing.shopName,
                        address: listing.location,
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 12),

            // ── Lokasyona Git ───────────────────────────────
            if (businessLatLng != null)
              _GoToLocationButton(
                listing: listing,
                businessLatLng: businessLatLng,
              ),
            const SizedBox(height: 24),

            // ── Rezervasyon Kartı ───────────────────────────
            _ReservationCard(
              listing: listing,
              quantity: quantity,
              totalPrice: totalPrice,
              onCancel: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.foodHome,
                (route) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Restoran başlık bileşeni
// ─────────────────────────────────────────────────────────────
class _RestaurantHeader extends StatelessWidget {
  const _RestaurantHeader({required this.listing});
  final FoodListing listing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF5ECD7),
            border: Border.all(color: AppColors.primaryColor, width: 2),
          ),
          child: const Icon(
            Icons.storefront_rounded,
            size: 26,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              listing.shopName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTextColor,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 14,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 2),
                Text(
                  listing.location.split('|').first.trim(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.hintTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Lokasyona Git butonu → NavigationView açar
// ─────────────────────────────────────────────────────────────
class _GoToLocationButton extends StatelessWidget {
  const _GoToLocationButton({
    required this.listing,
    required this.businessLatLng,
  });
  final FoodListing listing;
  final LatLng businessLatLng;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => NavigationView(
              latitude: businessLatLng.latitude,
              longitude: businessLatLng.longitude,
              businessName: listing.shopName,
              address: listing.location,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.primaryButtonGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          LocaleKeys.foodReservationConfirm_goToLocation.tr(),
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

// ─────────────────────────────────────────────────────────────
// Rezervasyon kartı
// ─────────────────────────────────────────────────────────────
class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.listing,
    required this.quantity,
    required this.totalPrice,
    required this.onCancel,
  });

  final FoodListing listing;
  final int quantity;
  final double totalPrice;
  final VoidCallback onCancel;

  String get _deliveryText {
    if (listing.deliveryStartTime == null) return listing.timeRange;
    final now = DateTime.now();
    final start = listing.deliveryStartTime!;
    final isToday =
        now.year == start.year &&
        now.month == start.month &&
        now.day == start.day;
    if (isToday)
      return '${LocaleKeys.common_pickupToday.tr()}  ${listing.timeRange}';
    final months = [
      '',
      LocaleKeys.foodReservationConfirm_months_jan.tr(),
      LocaleKeys.foodReservationConfirm_months_feb.tr(),
      LocaleKeys.foodReservationConfirm_months_mar.tr(),
      LocaleKeys.foodReservationConfirm_months_apr.tr(),
      LocaleKeys.foodReservationConfirm_months_may.tr(),
      LocaleKeys.foodReservationConfirm_months_jun.tr(),
      LocaleKeys.foodReservationConfirm_months_jul.tr(),
      LocaleKeys.foodReservationConfirm_months_aug.tr(),
      LocaleKeys.foodReservationConfirm_months_sep.tr(),
      LocaleKeys.foodReservationConfirm_months_oct.tr(),
      LocaleKeys.foodReservationConfirm_months_nov.tr(),
      LocaleKeys.foodReservationConfirm_months_dec.tr(),
    ];
    return '${start.day} ${months[start.month]}  ${listing.timeRange}';
  }

  String get _sectionLabel {
    switch (listing.section) {
      case FoodSection.nearYou:
        return LocaleKeys.foodReservationConfirm_sectionNearby.tr();
      case FoodSection.buyNow:
        return LocaleKeys.foodReservationConfirm_sectionBuyNow.tr();
      case FoodSection.todayPopular:
        return LocaleKeys.foodReservationConfirm_sectionTodayPopular.tr();
      case FoodSection.todayPopularAll:
        return LocaleKeys.foodReservationConfirm_sectionTodayPopularAll.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _sectionLabel,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.hintTextColor,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // Ürün resmi
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: listing.isNetworkImage
                      ? Image.network(
                          listing.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _errorPlaceholder(),
                        )
                      : Image.asset(
                          listing.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _errorPlaceholder(),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.shopName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: AppColors.hintTextColor,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            _deliveryText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.hintTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${totalPrice.toInt()} TL',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // İptal Et
          GestureDetector(
            onTap: onCancel,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryColor),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                LocaleKeys.foodReservationConfirm_cancel.tr(),
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF5ECD7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.fastfood_rounded, color: AppColors.primaryColor),
    );
  }
}
