import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';

/// 1-5 yıldız seçim widget'ı.
class ReviewStarInput extends StatelessWidget {
  const ReviewStarInput({
    super.key,
    required this.rating,
    required this.onChanged,
    this.size = 36,
    this.color = AppColors.primaryColor,
  });

  final int rating;
  final ValueChanged<int> onChanged;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final starValue = i + 1;
        return GestureDetector(
          onTap: () => onChanged(starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              starValue <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
              color: color,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}

/// Statik yıldız gösterimi (input değil, salt okunur).
class ReviewStarDisplay extends StatelessWidget {
  const ReviewStarDisplay({
    super.key,
    required this.rating,
    this.size = 16,
    this.color = const Color(0xFFFFC107),
  });

  final double rating;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(Icons.star_rounded, color: color, size: size);
        } else if (i < rating) {
          return Icon(Icons.star_half_rounded, color: color, size: size);
        } else {
          return Icon(Icons.star_outline_rounded, color: color, size: size);
        }
      }),
    );
  }
}
