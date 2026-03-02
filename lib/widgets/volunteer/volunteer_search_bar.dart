import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';

/// Gönüllü arama çubuğu widget'ı.
class VolunteerSearchBar extends StatelessWidget {
  const VolunteerSearchBar({
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
        border: Border.all(color: AppColors.volunteerColor.withValues(alpha: 0.3)), // İsteğe bağlı yeşil ince sınır
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
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.primaryTextColor,
        ),
        decoration: InputDecoration(
          hintText: 'Ara',
          hintStyle: const TextStyle(
            color: AppColors.hintTextColor,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.hintTextColor,
            size: 22,
          ),
          suffixIcon: const Icon(
            Icons.mic_none_rounded,
            color: AppColors.volunteerColor, // Yeşil mikrofon ikonu
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
