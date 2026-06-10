// ignore: unused_import
import 'dart:io'; // Required for Image.file() which takes dart:io.File
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';
import '../../models/app_module_type.dart';
import '../../utils/routes/app_routes.dart';
import '../../utils/theme/app_theme.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../viewmodels/food/food_profile_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/food/profile_menu_tile.dart';

class FoodProfileView extends StatelessWidget {
  const FoodProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FoodProfileBody();
  }
}

class _FoodProfileBody extends StatefulWidget {
  const _FoodProfileBody();

  @override
  State<_FoodProfileBody> createState() => _FoodProfileBodyState();
}

class _FoodProfileBodyState extends State<_FoodProfileBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodProfileViewModel>().fetchProfile();
    });
  }

  Widget _buildAvatar(FoodProfileViewModel vm) {
    const Color fallbackBg = Color(0xFFEADCC6);
    const Color fallbackIcon = Color(0xFFFE8800);

    if (vm.selectedImageFile != null) {
      return Image.file(
        vm.selectedImageFile!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      );
    }
    if (vm.remoteImageUrl != null && vm.remoteImageUrl!.isNotEmpty) {
      return Image.network(
        vm.remoteImageUrl!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 60,
          height: 60,
          color: fallbackBg,
          child: const Icon(Icons.person, size: 32, color: fallbackIcon),
        ),
      );
    }
    return Container(
      width: 60,
      height: 60,
      color: fallbackBg,
      child: const Icon(Icons.person, size: 32, color: fallbackIcon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FoodProfileViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(LocaleKeys.foodProfile_title.tr()),
        automaticallyImplyLeading: false,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // ─── Header: Avatar & User Info ─────────────────
            GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.foodProfileEdit),
              child: Row(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.foodProfileEdit),
                    child: SizedBox(
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
                                color: Color(0xFFFE8800),
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
                          vm.fullName,
                          style: CustomTextStyles.orelegaOne18DarkGrey,
                        ),
                        const SizedBox(height: 4),
                        Text(vm.email, style: CustomTextStyles.italic14Grey),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFFE8800),
                    size: 28,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Menu Container ──────────────────────────────
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
                    title: LocaleKeys.foodProfile_notifications.tr(),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.notification,
                      arguments: AppModuleType.food,
                    ),
                  ),
                  ProfileMenuTile(
                    icon: Icons.history_rounded,
                    title: LocaleKeys.foodProfile_history.tr(),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.foodOrdersHistory,
                    ),
                  ),
                  ProfileMenuTile(
                    icon: Icons.location_on_outlined,
                    title: LocaleKeys.foodProfile_addresses.tr(),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.addresses,
                      arguments: AppModuleType.food,
                    ),
                  ),
                  ProfileMenuTile(
                    icon: Icons.credit_card_rounded,
                    title: LocaleKeys.foodProfile_cards.tr(),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.cards,
                      arguments: AppModuleType.food,
                    ),
                  ),
                  ProfileMenuTile(
                    icon: Icons.person_outline_rounded,
                    title: LocaleKeys.foodProfile_updateProfile.tr(),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.foodProfileEdit),
                  ),
                  ProfileMenuTile(
                    icon: Icons.lock_outline_rounded,
                    title: LocaleKeys.foodProfile_changePassword.tr(),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.changePassword,
                      arguments: AppModuleType.food,
                    ),
                  ),
                  ProfileMenuTile(
                    icon: Icons.public,
                    title: LocaleKeys.foodProfile_changeLanguage.tr(),
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
                    isDestructive: false,
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
                Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
              }
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
  }
}
