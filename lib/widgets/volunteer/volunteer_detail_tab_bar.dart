import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/volunteer/volunteer_detail_viewmodel.dart';

class VolunteerDetailTabBar extends StatelessWidget {
  const VolunteerDetailTabBar({super.key, required this.vm});

  final VolunteerDetailViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _TabItem(
            label: "Sipariş",
            index: 0,
            selectedTab: vm.selectedTab,
            onTap: () => vm.onTabChanged(0),
          ),
          _TabItem(
            label: "Yorum",
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
                color: isSelected ? AppColors.volunteerColor : Colors.transparent,
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
              color: isSelected ? AppColors.volunteerColor : AppColors.hintTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
