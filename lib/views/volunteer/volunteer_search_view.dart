import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_module_type.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../utils/routes/app_routes.dart';
import '../../utils/theme/app_theme.dart';
import '../../viewmodels/volunteer/volunteer_search_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';

class VolunteerSearchView extends StatelessWidget {
  const VolunteerSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeFor(AppSection.volunteer),
      child: ChangeNotifierProvider(
        create: (_) => VolunteerSearchViewModel(),
        child: Consumer<VolunteerSearchViewModel>(
          builder: (context, vm, child) {
            return Scaffold(
              backgroundColor: const Color(0xFFF5F5F5),
              appBar: AppBar(
                title: Text(LocaleKeys.volunteerSearch_title.tr()),
              ),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search, size: 72,
                        color: AppColors.volunteerColor),
                    const SizedBox(height: 16),
                    Text(
                      LocaleKeys.volunteerSearch_comingSoon.tr(),
                      style: const TextStyle(
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
                onItemSelected: (index) => _handleNavigation(context, index),
                moduleType: AppModuleType.volunteer,
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 2) {
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
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
  }
}
