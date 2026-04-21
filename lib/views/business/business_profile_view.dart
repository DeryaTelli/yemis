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
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/food/profile_menu_tile.dart';
import '../../utils/theme/app_theme.dart';


class BusinessProfileView extends StatelessWidget {
  const BusinessProfileView({super.key});

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
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Header: Avatar & Kullanıcı Bilgisi ──────────────
                    Row(
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: Stack(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEADCC6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.store_rounded,
                                  size: 30,
                                  color: AppColors.primaryColor,
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
                                'Murat Pastanesi',
                                style: CustomTextStyles.orelegaOne18DarkGrey,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'muratpastanesi@gmail.com',
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

                    const SizedBox(height: 20),

                    // ─── Günlük Stats ─────────────────────────────────
                    const Text(
                      'Günlük',
                      style: TextStyle(
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
                        color: const Color(0xFFF5E4CA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          ProfileMenuTile(
                            icon: Icons.notifications_none_rounded,
                            title: LocaleKeys.businessProfile_notifications.tr(),
                            onTap: () {},
                          ),
                          ProfileMenuTile(
                            icon: Icons.bar_chart_rounded,
                            title: LocaleKeys.businessProfile_reports.tr(),
                            onTap: () {},
                          ),
                          ProfileMenuTile(
                            icon: Icons.history_rounded,
                            title: LocaleKeys.businessProfile_pastListings.tr(),
                            onTap: () {},
                          ),
                          ProfileMenuTile(
                            icon: Icons.check_circle_outline_rounded,
                            title: LocaleKeys.businessProfile_soldListings.tr(),
                            onTap: () {},
                          ),
                          ProfileMenuTile(
                            icon: Icons.unpublished_outlined,
                            title: LocaleKeys.businessProfile_unsoldListings.tr(),
                            onTap: () {},
                          ),
                          ProfileMenuTile(
                            icon: Icons.credit_card_rounded,
                            title: LocaleKeys.businessProfile_savedCards.tr(),
                            onTap: () {},
                          ),
                          ProfileMenuTile(
                            icon: Icons.manage_accounts_outlined,
                            title: LocaleKeys.businessProfile_updateProfile.tr(),
                            onTap: () {},
                          ),
                          ProfileMenuTile(
                            icon: Icons.lock_outline_rounded,
                            title: LocaleKeys.businessProfile_changePassword.tr(),
                            onTap: () {},
                          ),
                          ProfileMenuTile(
                            icon: Icons.public,
                            title: LocaleKeys.businessProfile_changeLanguage.tr(),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.languageSelect,
                                arguments: AppSection.food,
                              );
                            },
                          ),
                          ProfileMenuTile(
                            icon: Icons.logout_rounded,
                            title: 'Çıkış Yap',
                            onTap: () => vm.logout(context),
                          ),
                          ProfileMenuTile(
                            icon: Icons.delete_outline_rounded,
                            title: LocaleKeys.businessProfile_deleteAccount.tr(),
                            isDestructive: true,
                            showTrailing: false,
                            onTap: () => vm.deleteAccount(context),
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
}


