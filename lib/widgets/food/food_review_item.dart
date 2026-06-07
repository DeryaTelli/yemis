import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/food/food_review.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';

/// Tek bir yorum kartı.
class FoodReviewItem extends StatelessWidget {
  const FoodReviewItem({
    super.key,
    required this.review,
    this.accentColor = AppColors.primaryColor,
  });

  final FoodReview review;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${review.date.hour.toString().padLeft(2, '0')}:${review.date.minute.toString().padLeft(2, '0')}';
    final now = DateTime.now();
    final isToday =
        now.year == review.date.year &&
        now.month == review.date.month &&
        now.day == review.date.day;
    final dateStr = isToday
        ? LocaleKeys.foodReviewItem_today.tr(namedArgs: {'time': timeStr})
        : DateFormat('dd.MM.yyyy, HH:mm').format(review.date);

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
                        child: Image.network(
                          review.avatarUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.person_rounded,
                            color: accentColor,
                            size: 22,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.person_rounded,
                          color: accentColor,
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
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 9.0;
                final size = (constraints.maxWidth - spacing * 2) / 3;
                return Row(
                  children: List.generate(review.photoUrls.take(3).length, (
                    index,
                  ) {
                    final photoUrl = review.photoUrls[index];
                    return Padding(
                      padding: EdgeInsets.only(right: index == 2 ? 0 : spacing),
                      child: GestureDetector(
                        onTap: () => _showPhoto(context, photoUrl),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: SizedBox.square(
                            dimension: size,
                            child: Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: const Color(0xFFFFE0B2),
                                child: Icon(
                                  Icons.restaurant_rounded,
                                  color: accentColor,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEEEEEE), height: 1),
        ],
      ),
    );
  }

  void _showPhoto(BuildContext context, String photoUrl) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(18),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(photoUrl, fit: BoxFit.contain),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(dialogContext),
              icon: const Icon(Icons.close_rounded, color: Colors.white),
            ),
          ],
        ),
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
          return const Icon(
            Icons.star_rounded,
            color: Color(0xFFFFC107),
            size: 16,
          );
        } else if (i < rating) {
          return const Icon(
            Icons.star_half_rounded,
            color: Color(0xFFFFC107),
            size: 16,
          );
        } else {
          return const Icon(
            Icons.star_outline_rounded,
            color: Color(0xFFFFC107),
            size: 16,
          );
        }
      }),
    );
  }
}
