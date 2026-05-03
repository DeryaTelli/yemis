import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/utils/routes/app_routes.dart';
import '../../models/food/food_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/theme/text_styles_custom.dart';
import '../../viewmodels/food/food_home_viewmodel.dart';
import '../../widgets/food/food_listing_card.dart';

class FoodAllListingsView extends StatelessWidget {
  final String title;
  final List<FoodListing> listings;

  const FoodAllListingsView({
    super.key,
    required this.title,
    required this.listings,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: listings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = listings[index];
          return FoodListingCard(
            listing: item,
            width: double.infinity,
            imageHeight: 160,
            onFavoriteTap: () {
              try {
                context.read<FoodHomeViewModel>().toggleFavorite(item.id);
              } catch (_) {
                debugPrint('⚠️ [FoodAllListingsView] ViewModel bulunamadı.');
              }
            },
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.foodDetail,
              arguments: item,
            ),
          );
        },
      ),
    );
  }
}
