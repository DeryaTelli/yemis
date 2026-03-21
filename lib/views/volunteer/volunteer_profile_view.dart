import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_module_type.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../utils/routes/app_routes.dart';
import '../../utils/theme/app_theme.dart';
import '../../utils/theme/text_styles_custom.dart';
import '../../viewmodels/volunteer/volunteer_listings_viewmodel.dart';
import '../../viewmodels/volunteer/volunteer_profile_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/food/profile_menu_tile.dart';

class VolunteerProfileView extends StatelessWidget {
  const VolunteerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeFor(AppSection.volunteer),
      child: ChangeNotifierProvider(
        create: (_) => VolunteerProfileViewModel(),
        child: Consumer<VolunteerProfileViewModel>(
          builder: (context, vm, child) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Text(LocaleKeys.volunteerProfile_title.tr()),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    // ─── Header: Avatar & User Info ─────────────────
                    Row(
                      children: [
                        // Avatar
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: Stack(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.volunteerColor.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 32,
                                  color: AppColors.volunteerColor,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add_circle_outline,
                                    size: 20,
                                    color: AppColors.volunteerColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Name & Email
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Derya Telli',
                                style: CustomTextStyles.orelegaOne18DarkGrey,
                              ),
                              SizedBox(height: 4),
                              Text(
                                '2002derya2002@gmail.com',
                                style: CustomTextStyles.italic14Grey,
                              ),
                            ],
                          ),
                        ),
                        // Right Arrow
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.volunteerColor,
                          size: 28,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ─── Menu Container ──────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.volunteerColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          ProfileMenuTile(
                            icon: Icons.notifications_none_rounded,
                            title: LocaleKeys.volunteerProfile_notifications.tr(),
                            iconColor: AppColors.volunteerColor,
                            onTap: () {},
                          ),
                          ProfileMenuTile(
                            icon: Icons.public,
                            title: LocaleKeys.volunteerProfile_pastListings.tr(),
                            iconColor: AppColors.volunteerColor,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.volunteerListings,
                                arguments: VolunteerListingType.past,
                              );
                            },
                          ),
                          ProfileMenuTile(
                            icon: Icons.public,
                            title: LocaleKeys.volunteerProfile_attendedListings.tr(),
                            iconColor: AppColors.volunteerColor,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.volunteerListings,
                                arguments: VolunteerListingType.attended,
                              );
                            },
                          ),
                          ProfileMenuTile(
                            icon: Icons.public,
                            title: LocaleKeys.volunteerProfile_activeListings.tr(),
                            iconColor: AppColors.volunteerColor,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.volunteerListings,
                                arguments: VolunteerListingType.active,
                              );
                            },
                          ),
                          ProfileMenuTile(
                            icon: Icons.public,
                            title: LocaleKeys.volunteerProfile_savedAddresses.tr(),
                            iconColor: AppColors.volunteerColor,
                            onTap: () {},
                          ),
                          ProfileMenuTile(
                            icon: Icons.public,
                            title: LocaleKeys.volunteerProfile_savedCards.tr(),
                            iconColor: AppColors.volunteerColor,
                            onTap: () {},
                          ),
                          ProfileMenuTile(
                            icon: Icons.public,
                            title: LocaleKeys.volunteerProfile_changeLanguage.tr(),
                            iconColor: AppColors.volunteerColor,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.languageSelect,
                                arguments: AppSection.volunteer,
                              );
                            },
                          ),
                          ProfileMenuTile(
                            icon: Icons.delete_outline_rounded,
                            title: LocaleKeys.volunteerProfile_deleteAccount.tr(),
                            isDestructive: true,
                            showTrailing: false,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: AppBottomNavBar(
                selectedIndex: vm.selectedIndex,
                onItemSelected: (index) => _handleNavigation(context, index),
                moduleType: AppModuleType.volunteer,
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 2) {
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      }
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
      case 4:
        route = AppRoutes.volunteerProfile;
        break;
      default:
        return;
    }

    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }
}
