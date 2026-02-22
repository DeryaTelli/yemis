import 'package:flutter/material.dart';
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            colors: [banner.fromColor, banner.toColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: banner.toColor.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // ── Beyaz Dalga Efekti ─────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                child: const CustomPaint(
                  size: Size(double.infinity, 150),
                  painter: WavePainter(),
                ),
              ),
            ),

            // ── Metin — Sağ Alt ────────────────────────────
            Positioned(
              right: 28,
              bottom: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    banner.title,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 190,
                    child: Text(
                      banner.subtitle,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.55),
                        height: 1.4,
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
