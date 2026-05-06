import 'package:flutter/material.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../models/app_module_type.dart';
import '../../utils/constants/app_colors.dart';
import '../../services/food/api_food_service.dart';
import '../../services/auth/user_session.dart';
import '../../utils/routes/app_routes.dart';
import '../../viewmodels/food/food_favorites_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/food/food_listing_card.dart';

class FoodFavoritesView extends StatelessWidget {
  const FoodFavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FoodFavoritesBody();
  }
}

// ─────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────
class _FoodFavoritesBody extends StatefulWidget {
  const _FoodFavoritesBody();

  @override
  State<_FoodFavoritesBody> createState() => _FoodFavoritesBodyState();
}

class _FoodFavoritesBodyState extends State<_FoodFavoritesBody>
    with RouteAware {
  @override
  void initState() {
    super.initState();
    // Sayfaya ilk gelindiğinde listeyi güncelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FoodFavoritesViewModel>().refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FoodFavoritesViewModel>();
    final favorites = vm.favorites;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // ─── AppBar ───────────────────────────────────────
      appBar: AppBar(
        title: Text(LocaleKeys.foodFavorites_title.tr()),
        automaticallyImplyLeading: false,
      ),
      // ─── Body ─────────────────────────────────────────
      body: favorites.isEmpty
          ? _EmptyFavoritesState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = favorites[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: FoodListingCard(
                    listing: item,
                    width: double.infinity,
                    imageHeight: 140,
                    onFavoriteTap: () => vm.toggleFavorite(item.id),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.foodDetail,
                      arguments: item,
                    ),
                  ),
                );
              },
            ),

      // ─── Bottom Nav ───────────────────────────────────
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
            // Favorilerde kendi içinde tab değiştirme gerekirse
            context.read<FoodFavoritesViewModel>().onTabSelected(index);
          }
        },
        moduleType: AppModuleType.food,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Boş Durum Ekranı
// ─────────────────────────────────────────────────────
class _EmptyFavoritesState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_rounded,
              size: 52,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Henüz favori ilan yok',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Beğendiğin ilanlardaki  ♡  ikonuna\ntıklayarak favorilere ekleyebilirsin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
