import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';
import '../../models/app_module_type.dart';
import '../../utils/routes/app_routes.dart';
import '../../utils/theme/app_theme.dart';
import '../../viewmodels/food/food_profile_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/food/profile_menu_tile.dart';

class FoodProfileView extends StatelessWidget {
  const FoodProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FoodProfileViewModel(),
      child: const _FoodProfileBody(),
    );
  }
}

class _FoodProfileBody extends StatefulWidget {
  const _FoodProfileBody();

  @override
  State<_FoodProfileBody> createState() => _FoodProfileBodyState();
}

class _FoodProfileBodyState extends State<_FoodProfileBody> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FoodProfileViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profil',
          ),
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
                const SizedBox(width: 16),
                
                // Name & Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  [
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
                  color: Color(0xFFFE8800),
                  size: 28,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ─── Menu Container ──────────────────────────────
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
                    title: 'Bildirimler',
                    onTap: () {},
                  ),
                  ProfileMenuTile(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Geçmiş Rezervasyonlarım',
                    onTap: () {},
                  ),
                  ProfileMenuTile(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Kayıtlı Adreslerim',
                    onTap: () {},
                  ),
                  ProfileMenuTile(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Kayıtlı Kartlarım',
                    onTap: () {},
                  ),
                  ProfileMenuTile(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Profil Güncelle',
                    onTap: () {},
                  ),
                  ProfileMenuTile(
                    icon: Icons.workspace_premium_outlined,
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
                    icon: Icons.delete_outline_rounded,
                    title: 'Hesabı Sil',
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
        moduleType: AppModuleType.food,
      ),
    );
  }
}


