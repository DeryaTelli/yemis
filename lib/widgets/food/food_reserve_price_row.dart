import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/food/food_reserve_viewmodel.dart';

/// Fiyat satırı.
class FoodReservePriceRow extends StatelessWidget {
  const FoodReservePriceRow({super.key, required this.vm});

  final FoodReserveViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Fiyat',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryTextColor,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryBorderColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            vm.totalPriceText,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryTextColor,
            ),
          ),
        ),
      ],
    );
  }
}
