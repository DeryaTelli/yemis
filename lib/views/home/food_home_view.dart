import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/widgets/common/loading_overlay.dart';
import '../../models/app_module_type.dart';
import '../../viewmodels/home/food_home_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';

class FoodHomeView extends StatelessWidget {
  const FoodHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FoodHomeViewModel(),
      child: Consumer<FoodHomeViewModel>(
        builder: (context, vm, child) {
          return LoadingOverlay(
            isLoading: false,
            moduleType: AppModuleType.food,
            showChatHead: true,
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Text(
                  "Food Home - Tab ${vm.selectedIndex}",
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              bottomNavigationBar: AppBottomNavBar(
                selectedIndex: vm.selectedIndex,
                onItemSelected: vm.onTabSelected,
                moduleType: AppModuleType.food,
              ),
            ),
          );
        },
      ),
    );
  }
}
