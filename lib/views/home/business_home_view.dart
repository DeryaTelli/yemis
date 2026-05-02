import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_module_type.dart';
import '../../services/auth/user_session.dart';
import '../../viewmodels/home/business_home_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';

class BusinessHomeView extends StatelessWidget {
  const BusinessHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => BusinessHomeViewModel(userSession: ctx.read<UserSession>()),
      child: Consumer<BusinessHomeViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Text(
                "Business Home - Tab ${vm.selectedIndex}",
                style: const TextStyle(fontSize: 24),
              ),
            ),
            bottomNavigationBar: AppBottomNavBar(
              selectedIndex: vm.selectedIndex,
              onItemSelected: vm.onTabSelected,
              moduleType: AppModuleType.business,
            ),
          );
        },
      ),
    );
  }
}
