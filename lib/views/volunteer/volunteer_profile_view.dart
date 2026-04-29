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
      child: const _VolunteerProfileBody(),
    );
  }
}

class _VolunteerProfileBody extends StatefulWidget {
  const _VolunteerProfileBody();

  @override
  State<_VolunteerProfileBody> createState() => _VolunteerProfileBodyState();
}

class _VolunteerProfileBodyState extends State<_VolunteerProfileBody> {
  void _showPhotoSelectBS(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _BSOption(
                icon: Icons.camera_alt_rounded,
                title: 'Take from Camera',
                onTap: () => Navigator.pop(context),
              ),
              const Divider(height: 1),
              _BSOption(
                icon: Icons.photo_library_rounded,
                title: 'Choose from Gallery',
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VolunteerProfileViewModel>();

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
            GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.foodProfileEdit,
                arguments: AppSection.volunteer,
              ),
              child: Row(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: () => _showPhotoSelectBS(context),
                    child: SizedBox(
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
                  ),
                  const SizedBox(width: 16),

                  // Name & Email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vm.name} ${vm.surname}',
                          style: CustomTextStyles.orelegaOne18DarkGrey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vm.email,
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
            ),

            const SizedBox(height: 24),

            // ─── Menu Container ──────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.volunteerColor.withValues(alpha: 0.1),
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
                    icon: Icons.history_rounded,
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
                    icon: Icons.volunteer_activism,
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
                    icon: Icons.event_available,
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
                    icon: Icons.location_on_outlined,
                    title: LocaleKeys.volunteerProfile_savedAddresses.tr(),
                    iconColor: AppColors.volunteerColor,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.addresses,
                        arguments: AppModuleType.volunteer,
                      );
                    },
                  ),

                  ProfileMenuTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Profil Güncelle',
                    iconColor: AppColors.volunteerColor,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.foodProfileEdit,
                      arguments: AppSection.volunteer,
                    ),
                  ),
                  ProfileMenuTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Şifre Değiştir',
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
                    icon: Icons.logout_rounded,
                    title: 'Çıkış Yap',
                    iconColor: AppColors.volunteerColor,
                    onTap: () => vm.logout(context),
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

class _BSOption extends StatelessWidget {
  const _BSOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.volunteerColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.volunteerColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1B1B1B),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.volunteerColor,
      ),
    );
  }
}
