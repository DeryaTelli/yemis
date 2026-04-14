import 'package:flutter/material.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';
import '../../utils/constants/app_colors.dart';

/// Arama çubuğu widget'ı.
class FoodSearchBar extends StatelessWidget {
  const FoodSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: AppColors.primaryTextColor),
        decoration: InputDecoration(
          hintText: 'Ara',
          hintStyle: CustomTextStyles.semiBold16Grey,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primaryColor,
            size: 22,
          ),
          suffixIcon: const Icon(
            Icons.mic_none_rounded,
            color: AppColors.primaryColor,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
