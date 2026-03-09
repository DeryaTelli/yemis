import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_module_type.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../utils/routes/app_routes.dart';
import '../../utils/theme/app_theme.dart';
import '../../viewmodels/volunteer/volunteer_listings_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/volunteer/volunteer_listing_card.dart';

class VolunteerListingsView extends StatelessWidget {
  const VolunteerListingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Rota argümanlarından VolunteerListingType'ı alıyoruz
    final type = ModalRoute.of(context)?.settings.arguments as VolunteerListingType? 
        ?? VolunteerListingType.active;

    return Theme(
      data: AppTheme.themeFor(AppSection.volunteer),
      child: ChangeNotifierProvider(
        create: (_) => VolunteerListingsViewModel(type: type)..fetchListings(),
        child: const _VolunteerListingsBody(),
      ),
    );
  }
}

class _VolunteerListingsBody extends StatelessWidget {
  const _VolunteerListingsBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VolunteerListingsViewModel>();

    String title;
    switch (vm.type) {
      case VolunteerListingType.active:
        title = LocaleKeys.volunteerListings_activeTitle.tr();
        break;
      case VolunteerListingType.past:
        title = LocaleKeys.volunteerListings_pastTitle.tr();
        break;
      case VolunteerListingType.attended:
        title = LocaleKeys.volunteerListings_attendedTitle.tr();
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(title),
      ),
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.volunteerColor,
              ),
            )
          : vm.errorMessage != null
              ? Center(
                  child: Text(
                    vm.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : vm.listings.isEmpty
                  ? Center(
                      child: Text(
                        LocaleKeys.volunteerListings_emptyMessage.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.hintTextColor,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
                      itemCount: vm.listings.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final listing = vm.listings[index];
                        final isPast = vm.type == VolunteerListingType.past;

                        return Opacity(
                          opacity: isPast ? 0.6 : 1.0,
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
                    ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 4, // Profile tab is active
        onItemSelected: (index) => _handleNavigation(context, index),
        moduleType: AppModuleType.volunteer,
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 4) {
      Navigator.pop(context); // Go back to profile if already on profile tab
      return; 
    }
    
    if (index == 2) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.home, (route) => false);
      return;
    }

    String route;
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
      default:
        return;
    }

    Navigator.pushReplacementNamed(context, route);
  }
}
