import 'package:flutter/material.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';
import 'package:yemis/widgets/common/custom_text_field.dart';
import '../../models/home/ad_banner.dart';
import '../../utils/constants/app_colors.dart';
import 'wave_painter.dart';

/// Tekil reklam banner kartı.
/// Gradient arka plan, beyaz dalga efekti ve sağ alt metin içerir.
class BannerCard extends StatelessWidget {
  final AdBanner banner;

  const BannerCard({super.key, required this.banner});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.primaryButtonGradient),
      //   gradient: LinearGradient(
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //     colors: [banner.fromColor, banner.toColor],
      //   ),
      // ),
      child: Stack(
        children: [
          // ── Beyaz Dalga Efekti ─────────────────────────
          const Positioned(
            bottom: -1,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(double.infinity, 160),
              painter: WavePainter(),
            ),
          ),

          // ── Görsel — Sol Alt ──────────────────────────
          Positioned(
            left: 30,
            bottom: 30,
            child: Image.asset(
              banner.imagePath,
              height: 180,
              width: 150,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

          // ── Metin — Sağ Alt (Beyaz Alan) ────────────────
          Positioned(
            right: 24,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(banner.title, style: CustomTextStyles.orelegaOne32Primary),
                const SizedBox(height: 4),
                SizedBox(
                  width: 220,
                  child: Text(
                    banner.subtitle,
                    textAlign: TextAlign.right,
                    style: CustomTextStyles.semiBold16Grey,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
