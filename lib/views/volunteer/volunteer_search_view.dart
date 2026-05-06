import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_module_type.dart';
import '../../services/volunteer/mock_volunteer_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../utils/routes/app_routes.dart';
import '../../utils/theme/app_theme.dart';
import '../../viewmodels/volunteer/volunteer_search_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/common/search_app_bar_custom.dart';
import '../../widgets/common/search_map_view.dart';
import '../../widgets/volunteer/volunteer_filter_bottom_sheet.dart';
import '../../widgets/volunteer/volunteer_listing_card.dart';

import '../../widgets/common/loading_overlay.dart';

class VolunteerSearchView extends StatefulWidget {
  const VolunteerSearchView({super.key});

  @override
  State<VolunteerSearchView> createState() => _VolunteerSearchViewState();
}

class _VolunteerSearchViewState extends State<VolunteerSearchView> {
  final TextEditingController _searchController = TextEditingController();
  late final VolunteerSearchViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = VolunteerSearchViewModel(service: MockVolunteerService())..init();

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
    return Theme(
      data: AppTheme.themeFor(AppSection.volunteer),
      child: ChangeNotifierProvider.value(
        value: _vm,
        child: Consumer<VolunteerSearchViewModel>(
          builder: (context, vm, child) {
            return LoadingOverlay(
              isLoading: vm.isLoading,
              moduleType: AppModuleType.volunteer,
              child: Scaffold(
                backgroundColor: const Color(0xFFF5F5F5),
                appBar: SearchAppBarCustom(
                  searchController: _searchController,
                  onSearchChanged: vm.onSearchChanged,
                  onFilterTap: () => _showFilterBottomSheet(context, vm),
                  isMapView: vm.isMapView,
                  onViewModeChanged: vm.toggleViewMode,
                  accentColor: AppColors.volunteerColor,
                ),
                body: vm.isMapView
                    ? SearchMapView(
                        listings: vm.filteredListings,
                        accentColor: AppColors.volunteerColor,
                        onMarkerTap: (listing) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.volunteerDetail,
                            arguments: listing,
                          );
                        },
                      )
                    : _buildListView(vm),
                bottomNavigationBar: AppBottomNavBar(
                  selectedIndex: vm.selectedIndex,
                  onItemSelected: (index) =>
                      _handleNavigation(context, index, vm),
                  moduleType: AppModuleType.volunteer,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildListView(VolunteerSearchViewModel vm) {
    if (vm.filteredListings.isEmpty) {
      return Center(
        child: Text(
          vm.searchQuery.isEmpty
              ? LocaleKeys.volunteerSearch_comingSoon.tr()
              : LocaleKeys.common_noResults.tr(),
          style: const TextStyle(color: AppColors.hintTextColor, fontSize: 15),
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
          child: VolunteerListingCard(
            listing: listing,
            width: double.infinity,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.volunteerDetail,
                arguments: listing,
              );
            },
          ),
        );
      },
    );
  }

  void _handleNavigation(
    BuildContext context,
    int index,
    VolunteerSearchViewModel vm,
  ) {
    if (index == 2) {
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      }
      return;
    }

    String? route;
    switch (index) {
      case 0:
        route = AppRoutes.volunteerHome;
        break;
      case 1:
        route = AppRoutes.volunteerSearch;
        break;
      case 3:
        route = AppRoutes.volunteerAddListing;
        break;
      case 4:
        route = AppRoutes.volunteerProfile;
        break;
    }

    if (route != null && ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    } else {
      vm.onTabSelected(index);
    }
  }

  void _showFilterBottomSheet(BuildContext context, VolunteerSearchViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => VolunteerFilterBottomSheet(
        currentSort: vm.activeSortType,
        onSortSelected: vm.selectSortType,
      ),
    );
  }
}
