import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';

class ActionBtn extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const ActionBtn({
    super.key,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: filled ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryColor, width: 1.3),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: filled ? Colors.white : AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}
