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
  });

  final FoodListing listing;
  final VoidCallback onFavoriteTap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Resim Alanı ──────────────────────────
            Stack(
              children: [
                // Resim
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: Image.asset(
                      listing.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFFFE0B2),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          color: AppColors.primaryColor,
                          size: 40,
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
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        listing.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: listing.isFavorite ? Colors.red : Colors.grey,
                        size: 16,
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
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          listing.rating.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
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
              padding: const EdgeInsets.all(10),
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

                  // Kategori
                  Text(
                    listing.title,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.hintTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Zaman
                  Text(
                    listing.timeRange,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.hintTextColor,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Ayırıcı çizgi (kesikli)
                  const Divider(
                    color: Color(0xFFE0E0E0),
                    thickness: 1,
                    height: 1,
                  ),
                  const SizedBox(height: 6),

                  // Fiyat
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${listing.price.toInt()} TL',
                      style: const TextStyle(
                        fontSize: 15,
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
    );
  }
}
