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
import '../../widgets/volunteer/volunteer_listing_card.dart';

class VolunteerSearchView extends StatefulWidget {
  const VolunteerSearchView({super.key});

  @override
  State<VolunteerSearchView> createState() => _VolunteerSearchViewState();
}

class _VolunteerSearchViewState extends State<VolunteerSearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeFor(AppSection.volunteer),
      child: ChangeNotifierProvider(
        create: (_) =>
            VolunteerSearchViewModel(service: MockVolunteerService())..init(),
        child: Consumer<VolunteerSearchViewModel>(
          builder: (context, vm, child) {
            return Scaffold(
              backgroundColor: const Color(0xFFF5F5F5),
              appBar: SearchAppBarCustom(
                searchController: _searchController,
                onSearchChanged: vm.onSearchChanged,
                onFilterTap: () => _showFilterBottomSheet(context),
                isMapView: vm.isMapView,
                onViewModeChanged: vm.toggleViewMode,
                accentColor: AppColors.volunteerColor,
              ),
              body: vm.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.volunteerColor,
                      ),
                    )
                  : vm.isMapView
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildListView(VolunteerSearchViewModel vm) {
    if (vm.filteredListings.isEmpty) {
      return Center(child: Text(LocaleKeys.volunteerSearch_comingSoon.tr()));
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

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.volunteerSearch_title
                    .tr(), // Or a dynamic filter title
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text('Filtreleme seçenekleri burada olacak...'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.volunteerColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Uygula'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
