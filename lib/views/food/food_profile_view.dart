import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_module_type.dart';
import '../../utils/routes/app_routes.dart';
import '../../viewmodels/food/food_profile_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/common/home_app_bar.dart';

class FoodProfileView extends StatelessWidget {
  const FoodProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FoodProfileViewModel(),
      child: Consumer<FoodProfileViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            appBar: AppBar(
              title: Text('Profil'),
            ),
            body: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_outline, size: 72, color: Color(0xFFFE8800)),
                  SizedBox(height: 16),
                  Text(
                    'Profil sayfası yakında!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFE8800),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: AppBottomNavBar(
              selectedIndex: vm.selectedIndex,
              onItemSelected: (index) => _handleNavigation(context, index),
              moduleType: AppModuleType.food,
            ),
          );
        },
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 2) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      return;
    }

    String route;
    switch (index) {
      case 0:
        route = AppRoutes.foodHome;
        break;
      case 1:
        route = AppRoutes.foodSearch;
        break;
      case 3:
        route = AppRoutes.foodFavorites;
        break;
      case 4:
        route = AppRoutes.foodProfile;
        break;
      default:
        return;
    }

    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }
}
