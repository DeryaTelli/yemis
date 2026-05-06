import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';
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
    const double bWidth = 1.3;
    const double bRadius = 14.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 200,
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(bRadius),
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
                    borderRadius: BorderRadius.circular(bRadius - 2),
                    child: SizedBox(
                      height: imageHeight,
                      width: double.infinity,
                      child: listing.imageUrl.isEmpty
                          ? _errorIcon()
                          : (listing.isNetworkImage
                              ? Image.network(
                                  listing.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _errorIcon(),
                                )
                              : Image.asset(
                                  listing.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _errorIcon(),
                                )),
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
                  // User Logo (sol-alt)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: listing.userLogoUrl != null &&
                                listing.userLogoUrl!.isNotEmpty
                            ? (listing.userLogoUrl!.startsWith('http')
                                ? Image.network(
                                    listing.userLogoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person_rounded,
                                      color: AppColors.volunteerColor,
                                      size: 20,
                                    ),
                                  )
                                : Image.asset(
                                    listing.userLogoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person_rounded,
                                      color: AppColors.volunteerColor,
                                      size: 20,
                                    ),
                                  ))
                            : const Icon(
                                Icons.person_rounded,
                                color: AppColors.volunteerColor,
                                size: 20,
                              ),
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

                        const SizedBox(height: 12),

                        // Gönüllü Ol Butonu
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.volunteerBackgroundGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              LocaleKeys.volunteerDetail_becomeButton.tr(),
                              style: CustomTextStyles.semiBold13White,
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
      ),
    );
  }

  Widget _errorIcon() {
    return Container(
      color: AppColors.volunteerColor.withValues(alpha: 0.1),
      child: const Icon(
        Icons.volunteer_activism_rounded,
        color: AppColors.volunteerColor,
        size: 32,
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = AppColors.volunteerColor.withValues(alpha: 0.5)
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

class _GradientBorderPainter extends CustomPainter {
  _GradientBorderPainter({
    required this.gradient,
    required this.width,
    required this.borderRadius,
  });

  final Gradient gradient;
  final double width;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..shader = gradient.createShader(rect);

    final RRect rrect = RRect.fromRectAndRadius(
      rect.deflate(width / 2),
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) =>
      oldDelegate.gradient != gradient ||
      oldDelegate.width != width ||
      oldDelegate.borderRadius != borderRadius;
}
