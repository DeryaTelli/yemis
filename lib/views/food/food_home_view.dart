import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food/food_listing.dart';
import '../../services/food/mock_food_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart';
import '../../viewmodels/food/food_home_viewmodel.dart';
import '../../widgets/food/food_filter_chips.dart';
import '../../widgets/food/food_listing_section.dart';
import '../../widgets/food/food_map_section.dart';
import '../../widgets/food/food_search_bar.dart';

/// Yemek ana sayfası — tam MVVM ile uygulanmıştır.
class FoodHomeView extends StatelessWidget {
  const FoodHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FoodHomeViewModel(service: MockFoodService())..init(),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // ─── AppBar ──────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.location),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Yemiş avatar ikonu
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_pin_circle_rounded,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),

              // Konum adı
              Flexible(
                child: Text(
                  vm.isLoading ? 'Konum yükleniyor…' : vm.locationName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.white, size: 20),
            ],
          ),
        ),
      ),

      // ─── Body ────────────────────────────────────
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // ── Arama Barı ─────────────────────────────
                  FoodSearchBar(
                    controller: _searchController,
                    onChanged: vm.onSearchChanged,
                  ),
                  const SizedBox(height: 16),

                  // ── Harita Alanı ────────────────────────────
                  const FoodMapSection(),
                  const SizedBox(height: 16),

                  // ── Filtre Chip'leri ────────────────────────
                  FoodFilterChips(
                    selectedFilter: vm.selectedFilter,
                    onFilterChanged: vm.onFilterChanged,
                  ),
                  const SizedBox(height: 20),

                  // ── "Sana Yakın Yerler" başlığı ─────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sana Yakın Yerler',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
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
                  const SizedBox(height: 12),

                  // ── Sürpriz Kutu ────────────────────────────
                  const FoodListingSection(
                    title: 'Sürpriz Kutu',
                    section: FoodSection.surpriseBox,
                  ),
                  const SizedBox(height: 24),

                  // ── Şimdi Al ────────────────────────────────
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
    );
  }
}
