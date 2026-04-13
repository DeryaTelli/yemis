import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';

/// Bir gönüllü ilanı kartı.
class VolunteerListingCard extends StatelessWidget {
  const VolunteerListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.width,
    this.imageHeight = 110, // Küçültüldü
  });

  final VolunteerListing listing;
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
          color: const Color(0xFF8AE196), // Açık yeşil arka plan
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
                    height: imageHeight,
                    width: double.infinity,
                    child: Image.asset(
                      listing.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFE8F5E9),
                        child: const Icon(
                          Icons.volunteer_activism_rounded,
                          color: AppColors.volunteerColor,
                          size: 32,
                        ),
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
                      color: AppColors.volunteerColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.white,
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
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        // Kullanıcı Adı
                        Text(
                          listing.userName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),

                        // Başlık
                        Text(
                          listing.title,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryTextColor,
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
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryTextColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Column(
                      children: [
                        // Ayırıcı çizgi
                        CustomPaint(
                          painter: _DashedLinePainter(),
                          size: const Size(double.infinity, 1),
                        ),

                        const SizedBox(height: 6),

                        // Gönüllü Ol Butonu
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.volunteerBackgroundGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              LocaleKeys.volunteerDetail_becomeButton.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
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

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
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
