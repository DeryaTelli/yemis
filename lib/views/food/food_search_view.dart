import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_module_type.dart';
import '../../utils/routes/app_routes.dart';
import '../../viewmodels/food/food_search_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';

class FoodSearchView extends StatelessWidget {
  const FoodSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FoodSearchViewModel(),
      child: Consumer<FoodSearchViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            appBar: AppBar(title: Text('Arama')),
            body: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search, size: 72, color: Color(0xFFFE8800)),
                  SizedBox(height: 16),
                  Text(
                    'Arama sayfası yakında!',
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
        },
      ),
    );
  }
}
