import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../models/food/food_listing.dart';

/// Restoran adı ve teslim saati kartı.
class FoodReserveInfoCard extends StatelessWidget {
  const FoodReserveInfoCard({
    super.key,
    required this.listing,
    required this.deliveryText,
  });

  final FoodListing listing;
  final String deliveryText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // İşletme ikonu
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF5ECD7),
            border: Border.all(color: AppColors.primaryColor, width: 2),
          ),
          child: const Icon(
            Icons.storefront_rounded,
            size: 36,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 10),

        // Restoran adı
        Text(
          listing.shopName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryTextColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),

        // Teslim saati
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 15,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              deliveryText,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.hintTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
