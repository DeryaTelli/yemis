import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../viewmodels/food/food_detail_viewmodel.dart';

class FoodDetailTabBar extends StatelessWidget {
  const FoodDetailTabBar({super.key, required this.vm});

  final FoodDetailViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _TabItem(
            label: LocaleKeys.foodDetail_tabOrder.tr(),
            index: 0,
            selectedTab: vm.selectedTab,
            onTap: () => vm.onTabChanged(0),
          ),
          _TabItem(
            label: LocaleKeys.foodDetail_tabReview.tr(),
            index: 1,
            selectedTab: vm.selectedTab,
            onTap: () => vm.onTabChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.index,
    required this.selectedTab,
    required this.onTap,
  });

  final String label;
  final int index;
  final int selectedTab;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedTab;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primaryColor : AppColors.hintTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
