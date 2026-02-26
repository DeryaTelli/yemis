import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/utils/routes/app_routes.dart';
import '../../models/app_module_type.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/home/volunteer_home_viewmodel.dart';
import '../../utils/theme/app_theme.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';

/// Gönüllü ana sayfası
class VolunteerHomeView extends StatelessWidget {
  const VolunteerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeFor(AppSection.volunteer),
      child: ChangeNotifierProvider(
        create: (_) => VolunteerHomeViewModel(),
        child: Consumer<VolunteerHomeViewModel>(
          builder: (context, vm, child) {
            return Scaffold(
              backgroundColor: const Color(0xFFF5F5F5),
              appBar: AppBar(title: const Text('Gönüllü Ol')),
              body: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.volunteer_activism,
                      size: 72,
                      color: AppColors.volunteerColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Gönüllü sayfası yakında!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.volunteerColor,
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
                    return;
                  }

                  String route;
                  switch (index) {
                    case 0:
                      route = AppRoutes.volunteerHome;
                      break;
                    case 1:
                      route = AppRoutes.volunteerSearch;
                      break;
                    case 3:
                      route = AppRoutes.volunteerAddListing;
                      break;
                    case 4:
                      route = AppRoutes.volunteerProfile;
                      break;
                    default:
                      return;
                  }

                  if (ModalRoute.of(context)?.settings.name != route) {
                    Navigator.pushReplacementNamed(context, route);
                  }
                },
                moduleType: AppModuleType.volunteer,
              ),
            );
          },
        ),
      ),
    );
  }
}
