import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/utils/routes/app_routes.dart';
import '../../models/app_module_type.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/home/business_home_viewmodel.dart';
import '../../widgets/common/home_app_bar.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';

/// İşletme ana sayfası
class BusinessHomeView extends StatelessWidget {
  const BusinessHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BusinessHomeViewModel(),
      child: Consumer<BusinessHomeViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            appBar: HomeAppBar(
              title: vm.appBarTitle,
              backgroundColor: vm.appBarColor,
            ),
            body: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 72,
                    color: AppColors.primaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'İşletme paneli yakında!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: AppBottomNavBar(
              selectedIndex: vm.selectedIndex,
              onItemSelected: (index) {
                if (index == 2) {
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.home,
                      (route) => false,
                    );
                  }
                } else {
                  vm.onTabSelected(index);
                }
              },
              moduleType: AppModuleType.business,
            ),
          );
        },
      ),
    );
  }
}
