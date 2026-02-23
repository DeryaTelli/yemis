import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food/food_listing.dart';
import '../../services/food/mock_food_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../viewmodels/food/food_detail_viewmodel.dart';
import '../../widgets/food/food_order_tab.dart';
import '../../widgets/food/food_review_tab.dart';

/// Yemek ilan detay ekranı.
class FoodDetailView extends StatelessWidget {
  const FoodDetailView({super.key, required this.listing});

  final FoodListing listing;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FoodDetailViewModel(
        service: MockFoodService(),
        listingId: listing.id,
      )..init(),
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : Stack(
              children: [
                // ── Ana İçerik ────────────────────────────
                Column(
                  children: [
                    // Hero Resim
                    _HeroImage(listing: listing, vm: vm),

                    // Başlık Alanı
                    _HeaderSection(listing: listing),

                    // Tab Bar
                    _TabBar(vm: vm),

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
                  child: _BottomBar(vm: vm),
                ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Hero Resim
// ─────────────────────────────────────────────────────
class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.listing, required this.vm});

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

// ─────────────────────────────────────────────────────
// Başlık Alanı
// ─────────────────────────────────────────────────────
class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.listing});

  final FoodListing listing;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ürün Adı
                Text(
                  listing.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 6),

                // Saat aralığı
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        color: AppColors.primaryColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      listing.timeRange,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.hintTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Mesafe + Mağaza
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.primaryColor, size: 14),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        listing.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.hintTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Paylaş ikonu
          IconButton(
            onPressed: () {
              // TODO: Share
            },
            icon: const Icon(
              Icons.ios_share_rounded,
              color: AppColors.primaryColor,
              size: 22,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Tab Bar
// ─────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  const _TabBar({required this.vm});

  final FoodDetailViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _TabItem(
            label: LocaleKeys.foodDetail_tabOrder.tr(),
            index: 0,
            selectedTab: vm.selectedTab,
            onTap: () => vm.onTabChanged(0),
          ),
          _TabItem(
            label: LocaleKeys.foodDetail_tabReview.tr(),
            index: 1,
            selectedTab: vm.selectedTab,
            onTap: () => vm.onTabChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.index,
    required this.selectedTab,
    required this.onTap,
  });

  final String label;
  final int index;
  final int selectedTab;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedTab;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primaryColor : AppColors.hintTextColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Alt Bar: Fiyat + Rezerve Et
// ─────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.vm});

  final FoodDetailViewModel vm;

  @override
  Widget build(BuildContext context) {
    final listing = vm.listing;
    if (listing == null) return const SizedBox();

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Fiyat
          Text(
            '${listing.price.toInt()} TL',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryTextColor,
            ),
          ),
          const Spacer(),

          // Rezerve Et
          GestureDetector(
            onTap: () async {
              await vm.reserve();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${listing.title} için rezervasyon alındı!',
                    ),
                    backgroundColor: AppColors.primaryColor,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryButtonGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                LocaleKeys.foodDetail_reserveButton.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
