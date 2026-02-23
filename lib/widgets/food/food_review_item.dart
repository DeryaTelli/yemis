import 'package:flutter/material.dart';
import '../../models/food/food_review.dart';
import '../../utils/constants/app_colors.dart';

/// Tek bir yorum kartı.
class FoodReviewItem extends StatelessWidget {
  const FoodReviewItem({super.key, required this.review});

  final FoodReview review;

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${review.date.hour.toString().padLeft(2, '0')}:${review.date.minute.toString().padLeft(2, '0')}';
    final dateStr = 'Today, $timeStr';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Üst Satır: Avatar + İsim + Tarih ────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.commentAndSettingsBackground,
                child: review.avatarUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.asset(
                          review.avatarUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: AppColors.primaryColor,
                        size: 22,
                      ),
              ),
              const SizedBox(width: 10),

              // İsim + Tarih
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          review.reviewerName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryTextColor,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.hintTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Yıldızlar
                    _StarRow(rating: review.rating),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Yorum Metni ──────────────────────────────
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.hintTextColor,
              height: 1.5,
            ),
          ),

          // ── Fotoğraflar ──────────────────────────────
          if (review.photoUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.photoUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      review.photoUrls[index],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        width: 70,
                        height: 70,
                        color: const Color(0xFFFFE0B2),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          color: AppColors.primaryColor,
                          size: 28,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEEEEEE), height: 1),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 16);
        } else if (i < rating) {
          return const Icon(Icons.star_half_rounded, color: Color(0xFFFFC107), size: 16);
        } else {
          return const Icon(Icons.star_outline_rounded, color: Color(0xFFFFC107), size: 16);
        }
      }),
    );
  }
}
