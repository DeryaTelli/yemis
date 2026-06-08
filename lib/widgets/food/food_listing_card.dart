import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';
import 'package:yemis/utils/locale_keys.dart';
import '../../models/food/food_listing.dart';
import '../../utils/constants/app_colors.dart';

/// Bir yemek ilanı kartı.
class FoodListingCard extends StatelessWidget {
  const FoodListingCard({
    super.key,
    required this.listing,
    required this.onFavoriteTap,
    this.onTap,
    this.width,
    this.imageHeight = 110,
  });

  final FoodListing listing;
  final VoidCallback onFavoriteTap;
  final VoidCallback? onTap;
  final double? width;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    final bool isSoldOut = listing.isSoldOut;
    final bool isExpired =
        listing.deliveryEndTime != null &&
        DateTime.now().isAfter(listing.deliveryEndTime!);
    final bool isUnavailable = isSoldOut || isExpired;

    Widget cardContent = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Resim Alanı ──────────────────────────
          Stack(
            children: [
              // Resim
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: imageHeight,
                  width: double.infinity,
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

              // Favori butonu (sol-üst)
              Positioned(
                top: 8,
                left: 8,
                child: GestureDetector(
                  onTap: onFavoriteTap,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      listing.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: listing.isFavorite
                          ? Colors.red
                          : Colors.grey.shade400,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Rating badge (sağ-üst)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFC107),
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        listing.rating.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Business Logo (sol-alt)
              Positioned(
                bottom: 8,
                left: 6,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child:
                        listing.shopLogoUrl != null &&
                            listing.shopLogoUrl!.isNotEmpty
                        ? (listing.shopLogoUrl!.startsWith('http')
                              ? Image.network(
                                  listing.shopLogoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _shopPlaceholder(),
                                )
                              : Image.asset(
                                  listing.shopLogoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _shopPlaceholder(),
                                ))
                        : _shopPlaceholder(),
                  ),
                ),
              ),
            ],
          ),

          // ── Bilgi Alanı ──────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dükkan - Konum başlığı
                Text(
                  '${listing.shopName} - ${listing.location}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                // Kategori/Başlık
                Text(
                  listing.title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.hintTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),

                // Zaman
                Text(listing.timeRange, style: CustomTextStyles.regular14Grey),
                const SizedBox(height: 8),

                // Ayırıcı çizgi (kesikli)
                CustomPaint(
                  painter: _DashedLinePainter(),
                  size: const Size(double.infinity, 1),
                ),
                const SizedBox(height: 12),

                // Fiyatlar
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (listing.originalPrice != null &&
                          listing.originalPrice! > listing.price)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '${listing.originalPrice!.toInt()} TL',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.hintTextColor,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppColors.hintTextColor,
                              decorationThickness: 1.5,
                            ),
                          ),
                        ),
                      Text(
                        '${listing.price.toInt()} TL',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryTextColor,
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
    );

    if (isUnavailable) {
      cardContent = ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            cardContent,
            Positioned.fill(
              child: Container(color: Colors.white.withValues(alpha: 0.35)),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.02),
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSoldOut
                          ? Colors.red.withValues(alpha: 0.85)
                          : Colors.grey.shade800.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isSoldOut
                          ? LocaleKeys.businessListings_soldOut.tr()
                          : LocaleKeys.businessListings_expired.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: isUnavailable ? null : onTap,
      child: Container(
        width: width ?? 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: cardContent,
      ),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      color: const Color(0xFFFFE0B2),
      child: const Icon(
        Icons.restaurant_rounded,
        color: AppColors.primaryColor,
        size: 32,
      ),
    );
  }

  Widget _shopPlaceholder() {
    return Image.asset(
      'assets/images/placeholder_shop.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.storefront_rounded,
        color: AppColors.primaryColor,
        size: 20,
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = AppColors.primaryColor.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    var dashWidth = 4.0;
    var dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
