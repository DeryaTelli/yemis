import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food/food_listing.dart';
import '../../services/food/mock_food_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/food/food_detail_viewmodel.dart';
import '../../widgets/food/food_detail_bottom_bar.dart';
import '../../widgets/food/food_detail_header.dart';
import '../../widgets/food/food_detail_hero_image.dart';
import '../../widgets/food/food_detail_tab_bar.dart';
import '../../widgets/food/food_order_tab.dart';
import '../../widgets/food/food_review_tab.dart';

import '../../widgets/common/loading_overlay.dart';
import '../../models/app_module_type.dart';

/// Yemek ilan detay ekranı.
class FoodDetailView extends StatelessWidget {
  const FoodDetailView({super.key, required this.listing});

  final FoodListing listing;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          FoodDetailViewModel(service: MockFoodService(), listingId: listing.id)
            ..init(),
      child: _FoodDetailBody(listing: listing),
    );
  }
}

// ─────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────
class _FoodDetailBody extends StatelessWidget {
  const _FoodDetailBody({required this.listing});

  final FoodListing listing;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FoodDetailViewModel>();

    return LoadingOverlay(
      isLoading: vm.isLoading,
      moduleType: AppModuleType.food,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // ── Ana İçerik ────────────────────────────
            Column(
              children: [
                // Hero Resim
                FoodDetailHeroImage(listing: listing, vm: vm),

                // Başlık Alanı
                FoodDetailHeader(listing: listing),

                // Tab Bar
                FoodDetailTabBar(vm: vm),

                // Tab İçeriği
                Expanded(
                  child: vm.selectedTab == 0
                      ? const FoodOrderTab()
                      : const FoodReviewTab(),
                ),
              ],
            ),

            // ── Alt Fiyat + Rezerve Bar ───────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FoodDetailBottomBar(vm: vm),
            ),
          ],
        ),
      ),
    );
  }
}
