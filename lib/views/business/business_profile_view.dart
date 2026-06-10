import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/widgets/business/daily_stat_card.dart';
import '../../models/app_module_type.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../utils/routes/app_routes.dart';
import '../../utils/theme/text_styles_custom.dart';
import '../../viewmodels/business/business_profile_viewmodel.dart';
import '../../viewmodels/business/business_listings_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/food/profile_menu_tile.dart';
import '../../utils/theme/app_theme.dart';

class BusinessProfileView extends StatefulWidget {
  const BusinessProfileView({super.key});

  @override
  State<BusinessProfileView> createState() => _BusinessProfileViewState();
}

class _BusinessProfileViewState extends State<BusinessProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessProfileViewModel>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessProfileViewModel>(
      builder: (context, vm, _) {
        return Theme(
          data: AppTheme.themeFor(AppSection.food),
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(LocaleKeys.businessProfile_title.tr()),
              automaticallyImplyLeading: false,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.businessProfileEdit,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: Stack(
                            children: [
                              ClipOval(child: _buildAvatar(vm)),
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
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vm.fullName,
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
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primaryColor,
                          size: 28,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─── Günlük Stats ─────────────────────────────────
                  Text(
                    LocaleKeys.businessProfile_dailyLabel.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DailyStatCard(
                          imagePath: 'assets/businessIcon/sold.png',
                          label: LocaleKeys.businessProfile_soldCountLabel.tr(),
                          value: vm.dailySoldCount.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DailyStatCard(
                          imagePath: 'assets/businessIcon/earn.png',
                          label: LocaleKeys.businessProfile_earningsLabel.tr(),
                          value: vm.dailyTotalEarnings,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ─── Menü Container ────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        ProfileMenuTile(
                          icon: Icons.notifications_none_rounded,
                          title: LocaleKeys.businessProfile_notifications.tr(),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.notification,
                            arguments: AppModuleType.business,
                          ),
                        ),
                        ProfileMenuTile(
                          icon: Icons.bar_chart_rounded,
                          title: LocaleKeys.businessProfile_reports.tr(),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.businessReports,
                          ),
                        ),
                        ProfileMenuTile(
                          icon: Icons.list_alt_rounded,
                          title: LocaleKeys.businessProfile_addedListings.tr(),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.businessListings,
                            arguments: ListingType.active,
                          ),
                        ),
                        ProfileMenuTile(
                          icon: Icons.check_circle_outline_rounded,
                          title: LocaleKeys.businessProfile_soldOrdersTitle
                              .tr(),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.businessListings,
                            arguments: ListingType.sold,
                          ),
                        ),
                        ProfileMenuTile(
                          icon: Icons.unpublished_outlined,
                          title: LocaleKeys.businessProfile_expiredListings
                              .tr(),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.businessListings,
                            arguments: ListingType.expired,
                          ),
                        ),
                        ProfileMenuTile(
                          icon: Icons.credit_card_rounded,
                          title: LocaleKeys.businessProfile_savedCards.tr(),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.cards,
                            arguments: AppModuleType.business,
                          ),
                        ),
                        ProfileMenuTile(
                          icon: Icons.location_on_outlined,
                          title: LocaleKeys.addresses_title.tr(),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.addresses,
                              arguments: AppModuleType.business,
                            );
                          },
                        ),
                        ProfileMenuTile(
                          icon: Icons.manage_accounts_outlined,
                          title: LocaleKeys.businessProfile_updateProfile.tr(),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.businessProfileEdit,
                          ),
                        ),
                        ProfileMenuTile(
                          icon: Icons.lock_outline_rounded,
                          title: LocaleKeys.businessProfile_changePassword.tr(),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.changePassword,
                            arguments: AppModuleType.business,
                          ),
                        ),
                        ProfileMenuTile(
                          icon: Icons.public,
                          title: LocaleKeys.businessProfile_changeLanguage.tr(),
                          onTap: () async {
                            final changed = await Navigator.pushNamed<Object?>(
                              context,
                              AppRoutes.languageSelect,
                              arguments: AppSection.food,
                            );
                            if (changed == true && mounted) setState(() {});
                          },
                        ),
                        ProfileMenuTile(
                          icon: Icons.logout_rounded,
                          title: LocaleKeys.foodProfile_logout.tr(),
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
              moduleType: AppModuleType.business,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(BusinessProfileViewModel vm) {
    const Color fallbackBg = Color(0xFFEADCC6);
    const Color fallbackIcon = AppColors.primaryColor;

    if (vm.selectedImageFile != null) {
      return Image.file(
        vm.selectedImageFile!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      );
    }
    if (vm.imageUrl != null && vm.imageUrl!.isNotEmpty) {
      return Image.network(
        vm.imageUrl!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 60,
          height: 60,
          color: fallbackBg,
          child: const Icon(
            Icons.storefront_rounded,
            size: 30,
            color: fallbackIcon,
          ),
        ),
      );
    }
    return Container(
      width: 60,
      height: 60,
      color: fallbackBg,
      child: const Icon(
        Icons.storefront_rounded,
        size: 30,
        color: fallbackIcon,
      ),
    );
  }
}
