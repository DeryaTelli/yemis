import 'package:flutter/material.dart';
import '../../models/home/home_card_item.dart';
import '../../utils/theme/text_styles_custom.dart';

/// Ana ekran navigasyon kartı.
/// Gradient arka plan, taşan PNG ikon ve metin içerir.
class HomeCard extends StatelessWidget {
  final HomeCardItem item;
  final VoidCallback onTap;

  const HomeCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Gradient Kart ────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              gradient: item.gradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: item.gradient.colors.last.withValues(alpha: 0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: item.imageOnLeft
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: item.imageOnLeft
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: CustomTextStyles.orelegaOne32White),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle,
                      textAlign: item.imageOnLeft
                          ? TextAlign.right
                          : TextAlign.left,
                      style: CustomTextStyles.semiBold16WhiteCompact,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── PNG — Kartın Üstüne Taşan ────────────────────
          Positioned(
            top: -60,
            left: item.imageOnLeft ? -10 : null,
            right: item.imageOnLeft ? null : -10,
            child: Image.asset(
              item.imagePath,
              width: 140,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
