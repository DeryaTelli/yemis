import 'package:flutter/material.dart';
import '../../models/food/food_filter.dart';
import '../../utils/constants/app_colors.dart';

/// Filtre chip'leri satırı.
class FoodFilterChips extends StatelessWidget {
  const FoodFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final FoodFilter selectedFilter;
  final ValueChanged<FoodFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      child: Row(
        children: FoodFilter.values.map((filter) {
          final isSelected = filter == selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onFilterChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : const Color(0xFFE0E0E0),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  filter.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF555555),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
