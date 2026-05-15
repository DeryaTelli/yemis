import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_module_type.dart';
import '../../services/volunteer/i_volunteer_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../utils/routes/app_routes.dart';
import '../../utils/theme/app_theme.dart';
import '../../viewmodels/volunteer/volunteer_listings_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/volunteer/volunteer_listing_card.dart';
import '../../widgets/volunteer/volunteer_my_listing_card.dart';
import 'package:lottie/lottie.dart';
import '../../utils/theme/text_styles_custom.dart';

class VolunteerListingsView extends StatelessWidget {
  const VolunteerListingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Rota argümanlarından VolunteerListingType'ı alıyoruz
    final type =
        ModalRoute.of(context)?.settings.arguments as VolunteerListingType? ??
        VolunteerListingType.active;

    return Theme(
      data: AppTheme.themeFor(AppSection.volunteer),
      child: ChangeNotifierProvider(
        create: (ctx) => VolunteerListingsViewModel(
          type: type,
          volunteerService: ctx.read<IVolunteerService>(),
        )..fetchListings(),
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
      appBar: AppBar(title: Text(title)),
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.volunteerColor),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: vm.listings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final listing = vm.listings[index];
                final isPast = vm.type == VolunteerListingType.past;
                final isActive = vm.type == VolunteerListingType.active;

                Widget card = VolunteerListingCard(
                  listing: listing,
                  width: double.infinity,
                  onTap: () {
                    final route = isActive
                        ? AppRoutes.volunteerListingDetail
                        : AppRoutes.volunteerDetail;
                    Navigator.pushNamed(context, route, arguments: listing);
                  },
                );

                if (isActive) {
                  card = VolunteerMyListingCard(
                    listing: listing,
                    onEdit: () => vm.editListing(context, listing),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.volunteerListingDetail,
                        arguments: listing,
                      );
                    },
                  );

                  return Dismissible(
                    key: Key('volunteer_listing_${listing.id}'),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      final confirmed = await _showDeleteConfirmation(context);
                      if (confirmed == true) {
                        final success = await vm.deleteListing(listing.id);
                        if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(LocaleKeys.volunteerListings_deleteError.tr()),
                            ),
                          );
                        }
                        return success;
                      }
                      return false;
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    child: card,
                  );
                }

                return Opacity(opacity: isPast ? 0.6 : 1.0, child: card);
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
        context,
        AppRoutes.home,
        (route) => false,
      );
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

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFDF5F2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Lottie.asset(
                  'assets/lottie/account_delete.json',
                  width: 60,
                  height: 60,
                  repeat: true,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    LocaleKeys.volunteerListings_deleteTitle.tr(),
                    style: CustomTextStyles.orelegaOne30Primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              LocaleKeys.volunteerListings_deleteConfirm.tr(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(
                    LocaleKeys.common_no.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    LocaleKeys.common_yes.tr(),
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
