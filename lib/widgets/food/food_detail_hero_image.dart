import 'package:flutter/material.dart';
import '../../models/food/food_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/food/food_detail_viewmodel.dart';

class FoodDetailHeroImage extends StatelessWidget {
  const FoodDetailHeroImage({
    super.key,
    required this.listing,
    required this.vm,
  });

  final FoodListing listing;
  final FoodDetailViewModel vm;

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
              color: const Color(0xFFFFE0B2),
              child: const Icon(
                Icons.restaurant_rounded,
                color: AppColors.primaryColor,
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

          // Mağaza Logosu (sol alt)
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
                child: listing.shopLogoUrl != null &&
                        listing.shopLogoUrl!.isNotEmpty
                    ? Image.asset(
                        listing.shopLogoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.storefront_rounded,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                      )
                    : const Icon(
                        Icons.storefront_rounded,
                        color: AppColors.primaryColor,
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
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),
            ),
          ),

          // Favori butonu (sağ üst)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: GestureDetector(
              onTap: vm.toggleFavorite,
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
                child: Icon(
                  vm.listing?.isFavorite == true
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: vm.listing?.isFavorite == true
                      ? Colors.red
                      : const Color(0xFFFFC107),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
