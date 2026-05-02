import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food/food_listing.dart';
import '../../services/auth/user_session.dart';
import '../../services/food/api_food_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/food/food_home_viewmodel.dart';
import '../../widgets/food/food_filter_chips.dart';
import '../../widgets/food/food_listing_section.dart';
import '../../widgets/food/food_map_section.dart';
import '../../widgets/food/food_search_bar.dart';
import '../../models/app_module_type.dart';
import '../../widgets/common/home_app_bar.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/common/loading_overlay.dart';

/// Yemek ana sayfası — tam MVVM ile uygulanmıştır.
class FoodHomeView extends StatelessWidget {
  const FoodHomeView({super.key, required this.userSession});

  final UserSession userSession;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FoodHomeViewModel(
        service: ApiFoodService()..setToken(userSession.token ?? ''),
        userSession: userSession,
      )..init(),
      child: const _FoodHomeBody(),
    );
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

class _FoodHomeBodyState extends State<_FoodHomeBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FoodHomeViewModel>();

    return LoadingOverlay(
      isLoading: vm.isLoading,
      moduleType: AppModuleType.food,
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
              FoodMapSection(listings: vm.filteredListings),
              const SizedBox(height: 16),

              // ── Filtre Chip'leri ────────────────────────
              FoodFilterChips(
                selectedFilter: vm.selectedFilter,
                onFilterChanged: vm.onFilterChanged,
              ),
              const SizedBox(height: 20),

              // ── Sürpriz Kutu ────────────────────────────
              const FoodListingSection(
                title: 'Sürpriz Kutu',
                section: FoodSection.surpriseBox,
              ),
              const SizedBox(height: 24),

              // ── Sekarang Al ────────────────────────────────
              const FoodListingSection(
                title: 'Şimdi Al',
                section: FoodSection.buyNow,
              ),
              const SizedBox(height: 24),

              // ── Bugün Popüler Olanlar ────────────────────
              const FoodListingSection(
                title: 'Bugün Popüler Olanlar',
                section: FoodSection.todayPopular,
              ),
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
}
