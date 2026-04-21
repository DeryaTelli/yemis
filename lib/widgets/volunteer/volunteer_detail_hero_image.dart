import 'package:flutter/material.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../utils/constants/app_colors.dart';

class VolunteerDetailHeroImage extends StatelessWidget {
  const VolunteerDetailHeroImage({
    super.key,
    required this.listing,
  });

  final VolunteerListing listing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Arka plan resim
          Image.asset(
            listing.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => Container(
              color: const Color(0xFFE8F5E9),
              child: const Icon(
                Icons.volunteer_activism_rounded,
                color: AppColors.volunteerColor,
                size: 64,
              ),
            ),
          ),

          // Gradient overlay (alt kısımda solma)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),

          // Kullanıcı Logosu (sol alt)
          Positioned(
            bottom: 20,
            left: 16,
            child: Container(
              width: 48,
              height: 48,
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
                    ? Image.asset(
                        listing.userLogoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person_rounded,
                          color: AppColors.volunteerColor,
                          size: 24,
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: AppColors.volunteerColor,
                        size: 24,
                      ),
              ),
            ),
          ),

          // Geri butonu (sol üst)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.volunteerColor,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
