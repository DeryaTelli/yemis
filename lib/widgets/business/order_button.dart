import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';

class OrderButton extends StatelessWidget {
  final String label;
  final String imagePath;
  final VoidCallback onTap;

  const OrderButton({
    super.key,
    required this.label,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Image.asset(imagePath, width: 42, height: 42, fit: BoxFit.contain),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
