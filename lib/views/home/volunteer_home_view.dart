import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_module_type.dart';
import '../../services/auth/user_session.dart';
import '../../viewmodels/home/volunteer_home_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';

class VolunteerHomeView extends StatelessWidget {
  const VolunteerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          VolunteerHomeViewModel(userSession: ctx.read<UserSession>()),
      child: Consumer<VolunteerHomeViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Text(
                "Volunteer Home - Tab ${vm.selectedIndex}",
                style: const TextStyle(fontSize: 24),
              ),
            ),
            bottomNavigationBar: AppBottomNavBar(
              selectedIndex: vm.selectedIndex,
              onItemSelected: vm.onTabSelected,
              moduleType: AppModuleType.volunteer,
            ),
          );
        },
      ),
    );
  }
}
