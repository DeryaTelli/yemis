import 'package:flutter/material.dart';
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
    this.imageHeight = 110, // Default'u biraz küçülttük (130 -> 110)
  });

  final FoodListing listing;
  final VoidCallback onFavoriteTap;
  final VoidCallback? onTap;
  final double? width;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
        child: Padding(
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
                      child: Image.asset(
                        listing.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFFFE0B2),
                          child: const Icon(
                            Icons.restaurant_rounded,
                            color: AppColors.primaryColor,
                            size: 32,
                          ),
                        ),
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
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          listing.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: listing.isFavorite ? Colors.red : Colors.grey,
                          size: 14,
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
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFC107),
                            size: 10,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            listing.rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
                    Text(
                      listing.timeRange,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.hintTextColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Ayırıcı çizgi (kesikli)
                    const Divider(
                      color: AppColors.hintTextColor,
                      thickness: 0.5,
                      height: 1,
                    ),
                    const SizedBox(height: 12),

                    // Fiyat
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${listing.price.toInt()} TL',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
