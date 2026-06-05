import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../viewmodels/food/food_reserve_viewmodel.dart';

/// Adet artırma/azaltma satırı.
class FoodReserveQuantityRow extends StatelessWidget {
  const FoodReserveQuantityRow({super.key, required this.vm});

  final FoodReserveViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              LocaleKeys.foodReserve_quantity.tr(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryTextColor,
              ),
            ),
            const Spacer(),
            _StepperButton(icon: Icons.remove, onTap: vm.decrement),
            const SizedBox(width: 16),
            Text(
              '${vm.quantity}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTextColor,
              ),
            ),
            const SizedBox(width: 16),
            _StepperButton(icon: Icons.add, onTap: vm.increment),
          ],
        ),
        if (vm.quantityError != null) ...[
          const SizedBox(height: 8),
          Text(
            vm.quantityError!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Icon(icon, size: 22, color: AppColors.primaryTextColor),
      ),
    );
  }
}
