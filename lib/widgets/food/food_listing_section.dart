import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food/food_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart';
import '../../viewmodels/food/food_home_viewmodel.dart';
import 'food_listing_card.dart';

/// Bir bölüm başlığı + yatay kayan ilan kartları.
class FoodListingSection extends StatelessWidget {
  const FoodListingSection({
    super.key,
    required this.title,
    required this.section,
  });

  final String title;
  final FoodSection section;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FoodHomeViewModel>();
    final listings = vm.sectionListings(section);

    if (listings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Başlık Satırı ─────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTextColor,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.foodAllListings,
                arguments: {
                  'title': title,
                  'listings': listings,
                },
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Tümü',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Yatay Liste ───────────────────────────────
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: listings.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = listings[index];
              return FoodListingCard(
                listing: item,
                onFavoriteTap: () => vm.toggleFavorite(item.id),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.foodDetail,
                  arguments: item,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
