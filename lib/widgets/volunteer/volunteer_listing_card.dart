import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import 'package:provider/provider.dart';
import '../../services/auth/user_session.dart';

/// Bir gönüllü ilanı kartı.
class VolunteerListingCard extends StatelessWidget {
  const VolunteerListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onVolunteerTap,
    this.width,
    this.imageHeight = 110, // Küçültüldü
  });

  final VolunteerListing listing;
  final VoidCallback? onTap;
  final VoidCallback? onVolunteerTap;
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
        padding: const EdgeInsets.all(10),
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
                      child:
                          listing.userLogoUrl != null &&
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

                      // Gönüllü Bilgisi (Eğer birisi gönüllü olmuşsa)
                      if (listing.assignedVolunteerName != null &&
                          (listing.volunteerComment == null ||
                              listing.volunteerComment!.isEmpty))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F8E9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.volunteerColor.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.white,
                                  child: ClipOval(
                                    child:
                                        (listing.assignedVolunteerAvatar !=
                                                null &&
                                            listing
                                                .assignedVolunteerAvatar!
                                                .isNotEmpty)
                                        ? (listing.assignedVolunteerAvatar!
                                                  .startsWith('http')
                                              ? Image.network(
                                                  listing
                                                      .assignedVolunteerAvatar!,
                                                  width: 32,
                                                  height: 32,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.asset(
                                                  listing
                                                      .assignedVolunteerAvatar!,
                                                  width: 32,
                                                  height: 32,
                                                  fit: BoxFit.cover,
                                                ))
                                        : const Icon(
                                            Icons.person,
                                            color: AppColors.volunteerColor,
                                            size: 18,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        LocaleKeys
                                            .volunteerListingCard_volunteered
                                            .tr(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.volunteerColor,
                                        ),
                                      ),
                                      Text(
                                        listing.assignedVolunteerName!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.volunteerColor,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Yorum yoksa ama gönüllü olunmuşsa (Gönüllü İlanlarım kısmında)
                      if (listing.isAttended &&
                          (listing.volunteerComment == null ||
                              listing.volunteerComment!.isEmpty))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.volunteerColor.withValues(
                                alpha: 0.05,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.volunteerColor.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.notifications_active_outlined,
                                  size: 16,
                                  color: AppColors.volunteerColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        LocaleKeys
                                            .volunteerListingCard_noReviewYet
                                            .tr(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.volunteerColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Gonulluya yorum hatirlatmasi gonderilir.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.primaryTextColor
                                              .withValues(alpha: 0.72),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.volunteerColor.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'Bekleniyor',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.volunteerColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Yorum (Detaylı Tasarım: Avatar, Yıldızlar, Metin, Fotolar)
                      if (listing.isAttended &&
                          listing.volunteerComment != null &&
                          listing.volunteerComment!.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.volunteerColor.withValues(
                              alpha: 0.05,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.volunteerColor.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LocaleKeys.volunteerListingCard_volunteered
                                    .tr(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.volunteerColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.white,
                                    child: ClipOval(
                                      child:
                                          (listing.volunteerAvatar != null &&
                                              listing
                                                  .volunteerAvatar!
                                                  .isNotEmpty)
                                          ? (listing.volunteerAvatar!
                                                    .startsWith('http')
                                                ? Image.network(
                                                    listing.volunteerAvatar!,
                                                    width: 36,
                                                    height: 36,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.asset(
                                                    listing.volunteerAvatar!,
                                                    width: 36,
                                                    height: 36,
                                                    fit: BoxFit.cover,
                                                  ))
                                          : const Icon(
                                              Icons.person,
                                              color: AppColors.volunteerColor,
                                              size: 20,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              listing.volunteerName ??
                                                  listing.userName,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    AppColors.primaryTextColor,
                                              ),
                                            ),
                                            Text(
                                              listing.reviewCreatedAt ??
                                                  'Bugün, 09:12',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.hintTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        _StarRow(
                                          rating: listing.volunteerRating,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                listing.volunteerComment!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryTextColor,
                                  height: 1.5,
                                ),
                              ),
                              if (listing.reviewImages.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 60,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: listing.reviewImages.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 8),
                                    itemBuilder: (context, index) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          listing.reviewImages[index],
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      else if (listing.isAvailable &&
                          !listing.isAttended &&
                          listing.assignedVolunteerName == null)
                        // Gönüllü Ol Butonu (Hala aktif olanlar için)
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: onVolunteerTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.volunteerColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                LocaleKeys.volunteerDetail_becomeButton.tr(),
                                style: CustomTextStyles.semiBold13White,
                              ),
                            ),
                          ),
                        )
                      else if (!listing.isAvailable &&
                          listing.assignedVolunteerName == null &&
                          !listing.isAttended)
                        // Geçmiş ilanlarda kimse gönüllü olmamışsa uyarı
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 16,
                                  color: Colors.orange[700],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    LocaleKeys
                                        .volunteerListingCard_noVolunteerYet
                                        .tr(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                ),
                              ],
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

  Widget _errorIcon() {
    return Container(
      color: const Color(0xFFE8F5E9),
      child: const Center(
        child: Icon(
          Icons.volunteer_activism_rounded,
          color: AppColors.volunteerColor,
          size: 44,
        ),
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
