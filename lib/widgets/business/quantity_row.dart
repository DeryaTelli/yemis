import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/business/business_add_order_viewmodel.dart';
import 'circle_btn.dart';

class QuantityRow extends StatelessWidget {
  const QuantityRow({super.key, required this.vm});
  final BusinessAddOrderViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleBtn(
          icon: Icons.remove,
          onTap: vm.decrementQuantity,
        ),
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
        CircleBtn(
          icon: Icons.add,
          onTap: vm.incrementQuantity,
        ),
      ],
    );
  }
}
