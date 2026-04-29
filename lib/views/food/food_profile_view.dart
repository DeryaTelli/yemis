import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';
import '../../models/app_module_type.dart';
import '../../utils/routes/app_routes.dart';
import '../../utils/theme/app_theme.dart';
import '../../utils/constants/app_colors.dart';
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
    final vm = context.watch<FoodProfileViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Profil')),

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
                    onTap: () => _showPhotoSelectBS(context),
                    child: SizedBox(
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
                              Icons.person,
                              size: 32,
                              color: Color(0xFFFE8800),
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
                          '${vm.name} ${vm.surname}',
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
                    title: 'Bildirimler',
                    onTap: () {},
                  ),
                  ProfileMenuTile(
                    icon: Icons.history_rounded,
                    title: 'Geçmiş Rezervasyonlarım',
                    onTap: () {},
                  ),
                  ProfileMenuTile(
                    icon: Icons.location_on_outlined,
                    title: 'Kayıtlı Adreslerim',
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.addresses,
                      arguments: AppModuleType.food,
                    ),
                  ),
                  ProfileMenuTile(
                    icon: Icons.credit_card_rounded,
                    title: 'Kayıtlı Kartlarım',
                    onTap: () {},
                  ),
                  ProfileMenuTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Profil Güncelle',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.foodProfileEdit),
                  ),
                  ProfileMenuTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Şifre Değiştir',
                    onTap: () {},
                  ),
                  ProfileMenuTile(
                    icon: Icons.public,
                    title: 'Dil Değiştir',
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
          color: AppColors.primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1B1B1B),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.primaryColor,
      ),
    );
  }
}
