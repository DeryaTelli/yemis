import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';

class FoodImage extends StatelessWidget {
  final String? imageUrl;
  const FoodImage({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 160,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => _placeholder,
            )
          : _placeholder,
    );
  }

  Widget get _placeholder => Container(
        color: const Color(0xFFEEE0D4),
        child: const Center(
          child: Icon(
            Icons.restaurant_rounded,
            size: 56,
            color: AppColors.primaryColor,
          ),
        ),
      );
}
