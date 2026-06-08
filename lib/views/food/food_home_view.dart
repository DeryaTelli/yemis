import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../models/food/food_listing.dart';
import '../../services/auth/user_session.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart';
import '../../viewmodels/food/food_home_viewmodel.dart';
import '../../widgets/food/food_filter_chips.dart';
import '../../widgets/food/food_active_order_card.dart';
import '../../widgets/food/food_listing_section.dart';
import '../../widgets/food/food_listing_card.dart';
import '../../widgets/food/food_map_section.dart';
import '../../widgets/food/food_search_bar.dart';
import '../../models/app_module_type.dart';
import '../../widgets/common/home_app_bar.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../services/review/i_review_service.dart';
import '../../services/auth/i_auth_service.dart';
import '../../widgets/review/mandatory_order_review_dialog.dart';

/// Yemek ana sayfası — tam MVVM ile uygulanmıştır.
class FoodHomeView extends StatelessWidget {
  const FoodHomeView({super.key, required this.userSession});

  final UserSession userSession;

  @override
  Widget build(BuildContext context) {
    return const _FoodHomeBody();
  }
}

// ─────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────
class _FoodHomeBody extends StatefulWidget {
  const _FoodHomeBody();

  @override
  State<_FoodHomeBody> createState() => _FoodHomeBodyState();
}

class _FoodHomeBodyState extends State<_FoodHomeBody>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  bool _isReviewDialogOpen = false;
  bool _isCheckingOrderStatus = false;
  Timer? _orderStatusTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Sayfaya gelindiğinde verileri yükle/güncelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FoodHomeViewModel>().init();
        _startOrderStatusTracking();
      }
    });
  }

  @override
  void dispose() {
    _orderStatusTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _startOrderStatusTracking();
      _checkOrderStatus();
    } else {
      _orderStatusTimer?.cancel();
    }
  }

  void _startOrderStatusTracking() {
    _orderStatusTimer?.cancel();
    _orderStatusTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkOrderStatus(),
    );
  }

  Future<void> _checkOrderStatus() async {
    if (!mounted || _isReviewDialogOpen || _isCheckingOrderStatus) return;

    _isCheckingOrderStatus = true;
    try {
      await context.read<FoodHomeViewModel>().refreshOrders();
    } finally {
      _isCheckingOrderStatus = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FoodHomeViewModel>();
    _showMandatoryReviewIfNeeded(vm);

    return LoadingOverlay(
      isLoading: vm.isLoading,
      moduleType: AppModuleType.food,
      showChatHead: true,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        // ─── AppBar ──────────────────────────────────
        appBar: HomeAppBar(
          title: vm.appBarTitle,
          backgroundColor: vm.appBarColor,
          isLocationTitle: true,
          moduleType: AppModuleType.food,
        ),

        // ─── Body ────────────────────────────────────
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //const SizedBox(height: 16),

              // ── Arama Barı ─────────────────────────────
              FoodSearchBar(
                controller: _searchController,
                onChanged: vm.onSearchChanged,
              ),
              const SizedBox(height: 16),

              // ── Harita Alanı ────────────────────────────
              FoodMapSection(
                listings: vm.filteredListings,
                userLat: vm.userLat,
                userLng: vm.userLng,
              ),
              const SizedBox(height: 16),

              if (vm.activeOrders.isNotEmpty) ...[
                FoodActiveOrderCard(
                  orders: vm.activeOrders,
                  onCancel: vm.cancelOrder,
                  onRefresh: vm.refreshOrders,
                ),
                const SizedBox(height: 18),
              ],

              if (vm.isSearching) ...[
                _FoodSearchResults(vm: vm),
                const SizedBox(height: 20),
              ],

              // ── Filtre Chip'leri ────────────────────────
              FoodFilterChips(
                selectedFilter: vm.selectedFilter,
                onFilterChanged: vm.onFilterChanged,
              ),
              const SizedBox(height: 20),

              if (!vm.isSearching) ...[
                FoodListingSection(
                  title: LocaleKeys.home_nearbyPlaces.tr(),
                  section: FoodSection.nearYou,
                ),
                const SizedBox(height: 24),
                FoodListingSection(
                  title: LocaleKeys.home_buyNow.tr(),
                  section: FoodSection.buyNow,
                ),
                const SizedBox(height: 24),
                FoodListingSection(
                  title: LocaleKeys.home_todayPopular.tr(),
                  section: FoodSection.todayPopular,
                ),
                const SizedBox(height: 24),
                FoodListingSection(
                  title: LocaleKeys.home_todayPopularAll.tr(),
                  section: FoodSection.todayPopularAll,
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNavBar(
          selectedIndex: vm.selectedIndex,
          onItemSelected: (index) {
            final route = vm.getBottomNavRoute(index);

            if (route != null) {
              if (index == 2) {
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    route,
                    (r) => false,
                  );
                }
              } else if (ModalRoute.of(context)?.settings.name != route) {
                Navigator.pushReplacementNamed(context, route);
              }
            } else {
              vm.onTabSelected(index);
            }
          },
          moduleType: AppModuleType.food,
        ),
      ),
    );
  }

  void _showMandatoryReviewIfNeeded(FoodHomeViewModel vm) {
    final order = vm.pendingReviewOrder;
    if (order == null || _isReviewDialogOpen) return;

    _isReviewDialogOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final submitted = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          fullscreenDialog: true,
          builder: (_) => MandatoryOrderReviewDialog(
            order: order,
            reviewService: context.read<IReviewService>(),
            authService: context.read<IAuthService>(),
          ),
        ),
      );
      if (!mounted) return;
      _isReviewDialogOpen = false;
      if (submitted == true) await vm.onReviewSubmitted(order.id);
    });
  }
}

class _FoodSearchResults extends StatelessWidget {
  const _FoodSearchResults({required this.vm});

  final FoodHomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    final results = vm.searchResults;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'foodSearch.results'.tr(
            namedArgs: {'count': results.length.toString()},
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryTextColor,
          ),
        ),
        const SizedBox(height: 10),
        if (results.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              'foodSearch.empty'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.hintTextColor,
                fontSize: 14,
              ),
            ),
          )
        else
          SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: results.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final listing = results[index];
                return FoodListingCard(
                  listing: listing,
                  onFavoriteTap: () => vm.toggleFavorite(listing.id),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.foodDetail,
                    arguments: listing,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
