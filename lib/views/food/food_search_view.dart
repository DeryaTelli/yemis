import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_module_type.dart';
import '../../services/food/mock_food_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart';
import '../../viewmodels/food/food_search_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/common/search_app_bar_custom.dart';
import '../../widgets/common/search_map_view.dart';
import '../../widgets/food/food_filter_bottom_sheet.dart';
import '../../widgets/food/food_listing_card.dart';

class FoodSearchView extends StatefulWidget {
  const FoodSearchView({super.key});

  @override
  State<FoodSearchView> createState() => _FoodSearchViewState();
}

class _FoodSearchViewState extends State<FoodSearchView> {
  final TextEditingController _searchController = TextEditingController();
  late final FoodSearchViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = FoodSearchViewModel(service: MockFoodService())..init();

    // Arama çubuğundaki değişiklikler her zaman ViewModel ile senkron kalır.
    _searchController.addListener(() {
      _vm.onSearchChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<FoodSearchViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            appBar: SearchAppBarCustom(
              searchController: _searchController,
              onSearchChanged: vm.onSearchChanged,
              onFilterTap: () => _showFilterBottomSheet(context, vm),
              isMapView: vm.isMapView,
              onViewModeChanged: vm.toggleViewMode,
            ),
            body: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  )
                : vm.isMapView
                    ? SearchMapView(
                        listings: vm.filteredListings,
                        accentColor: AppColors.primaryColor,
                        onMarkerTap: (listing) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.foodDetail,
                            arguments: listing,
                          );
                        },
                      )
                    : _buildListView(vm),
            bottomNavigationBar: AppBottomNavBar(
              selectedIndex: vm.selectedIndex,
              onItemSelected: (index) {
                final route = vm.getBottomNavRoute(index);
                if (route != null) {
                  if (index == 2) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, route, (r) => false);
                  } else if (ModalRoute.of(context)?.settings.name != route) {
                    Navigator.pushReplacementNamed(context, route);
                  }
                } else {
                  vm.onTabSelected(index);
                }
              },
              moduleType: AppModuleType.food,
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView(FoodSearchViewModel vm) {
    if (vm.filteredListings.isEmpty) {
      return const Center(
        child: Text(
          'Sonuç bulunamadı.',
          style: TextStyle(color: AppColors.hintTextColor, fontSize: 15),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.filteredListings.length,
      itemBuilder: (context, index) {
        final listing = vm.filteredListings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FoodListingCard(
            listing: listing,
            width: double.infinity,
            onFavoriteTap: () => vm.toggleFavorite(listing.id),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.foodDetail,
                arguments: listing,
              );
            },
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context, FoodSearchViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FoodFilterBottomSheet(
        currentSort: vm.activeSortType,
        onSortSelected: vm.selectSortType,
      ),
    );
  }
}
