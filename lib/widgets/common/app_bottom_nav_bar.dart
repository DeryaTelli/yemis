import 'package:flutter/material.dart';
import '../../models/app_module_type.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_icons.dart';
import 'center_home_button.dart';
import 'nav_bar_item.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.moduleType,
  });

  final int selectedIndex;
  final Function(int) onItemSelected;
  final AppModuleType moduleType;

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = moduleType == AppModuleType.volunteer 
        ? const Color(0xFF22B05A) 
        : AppColors.primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 50, // Exact Figma content height
            child: Row(
              children: [
                NavBarItem(
                  icon: AppIcons.home,
                  isSelected: selectedIndex == 0,
                  onTap: () => onItemSelected(0),
                  selectedColor: selectedColor,
                ),
                NavBarItem(
                  icon: _getSecondIcon(),
                  isSelected: selectedIndex == 1,
                  onTap: () => onItemSelected(1),
                  selectedColor: selectedColor,
                ),
                Expanded(
                  child: Center(
                    child: CenterHomeButton(
                      isSelected: selectedIndex == 2,
                      onTap: () => onItemSelected(2),
                    ),
                  ),
                ),
                NavBarItem(
                  icon: _getFourthIcon(),
                  isSelected: selectedIndex == 3,
                  onTap: () => onItemSelected(3),
                  selectedColor: selectedColor,
                ),
                NavBarItem(
                  icon: AppIcons.profile,
                  isSelected: selectedIndex == 4,
                  onTap: () => onItemSelected(4),
                  selectedColor: selectedColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSecondIcon() {
    switch (moduleType) {
      case AppModuleType.food:
      case AppModuleType.volunteer:
        return AppIcons.search;
      case AppModuleType.business:
        return AppIcons.approvals;
    }
  }

  String _getFourthIcon() {
    switch (moduleType) {
      case AppModuleType.food:
        return AppIcons.favorite;
      case AppModuleType.volunteer:
        return AppIcons.addVolunteer;
      case AppModuleType.business:
        return AppIcons.addBusiness;
    }
  }
}
