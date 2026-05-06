import 'package:flutter/material.dart';
import '../../models/review/review_model.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'review_star_input.dart';

/// Ortak yorum liste kartı — Food ve Volunteer için kullanılır.
///
/// [isOwn] true ise sağ üstte Düzenle/Sil menüsü gösterilir.
class ReviewListItem extends StatelessWidget {
  const ReviewListItem({
    super.key,
    required this.review,
    this.onEdit,
    this.onDelete,
    this.accentColor = AppColors.primaryColor,
  });

  final ReviewModel review;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Color accentColor;

  String get _dateStr {
    final now = DateTime.now();
    final diff = now.difference(review.date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce'; // Bu kısım için şimdilik kalsın veya genelleştirilebilir
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    if (diff.inDays == 1) return 'Dün';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return '${review.date.day}.${review.date.month}.${review.date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Üst Satır: Avatar + İsim + Tarih + Menü ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: accentColor.withValues(alpha: 0.15),
                child: Icon(
                  Icons.person_rounded,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),

              // İsim + Yıldız
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
                        // Tarih
                        Text(
                          _dateStr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.hintTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ReviewStarDisplay(rating: review.rating),
                  ],
                ),
              ),

              // Düzenle/Sil menüsü (sadece kendi yorumunda)
              if (review.isOwn && (onEdit != null || onDelete != null))
                _OwnerMenu(
                  onEdit: onEdit,
                  onDelete: onDelete,
                  accentColor: accentColor,
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

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEEEEEE), height: 1),
        ],
      ),
    );
  }
}

class _OwnerMenu extends StatelessWidget {
  const _OwnerMenu({
    this.onEdit,
    this.onDelete,
    required this.accentColor,
  });

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, size: 20, color: accentColor),
      padding: EdgeInsets.zero,
      onSelected: (value) {
        if (value == 'edit') onEdit?.call();
        if (value == 'delete') onDelete?.call();
      },
      itemBuilder: (_) => [
        if (onEdit != null)
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 18, color: accentColor),
                const SizedBox(width: 8),
                Text(LocaleKeys.common_edit.tr()),
              ],
            ),
          ),
        if (onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Text(LocaleKeys.common_delete.tr(), style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
      ],
    );
  }
}
