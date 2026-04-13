import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/food/food_reserve_viewmodel.dart';
import 'food_reserve_bottom_sheet.dart';

/// Ödeme yöntemi satırı.
///
/// Seçilmemişse "+ Bir Ödeme Yöntemi Seç" (turuncu), seçilmişse yöntem adı gösterilir.
/// Tıklandığında bottom sheet açılır.
class FoodReservePaymentRow extends StatelessWidget {
  const FoodReservePaymentRow({super.key, required this.vm});

  final FoodReserveViewModel vm;

  void _showPaymentSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FoodReserveBottomSheet(vm: vm),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPayment = vm.selectedPayment != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ödeme Yöntemi',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryTextColor,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _showPaymentSheet(context),
          child: Row(
            children: [
              if (!hasPayment)
                const Icon(Icons.add, size: 18, color: AppColors.primaryColor),
              if (!hasPayment) const SizedBox(width: 4),
              Text(
                hasPayment
                    ? vm.selectedPayment!.label
                    : 'Bir Ödeme Yöntemi Seç',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: hasPayment
                      ? AppColors.primaryTextColor
                      : AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
