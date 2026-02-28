import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_module_type.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart';
import '../../viewmodels/food/food_favorites_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/food/food_listing_card.dart';

class FoodFavoritesView extends StatelessWidget {
  const FoodFavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FoodFavoritesViewModel(),
      child: const _FoodFavoritesBody(),
    );
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sayfaya her dönüldüğünde listeyi güncelle
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
      appBar: AppBar(title: const Text('Favori')),
      // ─── Body ─────────────────────────────────────────
      body: favorites.isEmpty
          ? _EmptyFavoritesState()
          : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 240,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final item = favorites[index];
                return FoodListingCard(
                  listing: item,
                  onFavoriteTap: () => vm.toggleFavorite(item.id),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.foodDetail,
                    arguments: item,
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
