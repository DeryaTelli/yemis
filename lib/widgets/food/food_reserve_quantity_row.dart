import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/food/food_reserve_viewmodel.dart';

/// Adet artırma/azaltma satırı.
class FoodReserveQuantityRow extends StatelessWidget {
  const FoodReserveQuantityRow({super.key, required this.vm});

  final FoodReserveViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Adet Sayısı',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryTextColor,
          ),
        ),
        const Spacer(),
        // Azalt
        _StepperButton(
          icon: Icons.remove,
          onTap: vm.decrement,
        ),
        const SizedBox(width: 16),
        // Adet
        Text(
          '${vm.quantity}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryTextColor,
          ),
        ),
        const SizedBox(width: 16),
        // Artır
        _StepperButton(
          icon: Icons.add,
          onTap: vm.increment,
        ),
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
