import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/food/food_reserve_viewmodel.dart';
import '../../utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';

/// Ödeme yöntemi seçim bottom sheet'i.
class FoodReserveBottomSheet extends StatelessWidget {
  const FoodReserveBottomSheet({super.key, required this.vm});

  final FoodReserveViewModel vm;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _PaymentTile(
              label: LocaleKeys.foodReserve_googlePay.tr(),
              onTap: () {
                vm.selectPayment(PaymentMethod.googlePay);
                Navigator.pop(context);
              },
            ),
            const Divider(height: 1, indent: 20, endIndent: 20),
            _PaymentTile(
              label: LocaleKeys.foodReserve_applePay.tr(),
              onTap: () {
                vm.selectPayment(PaymentMethod.applePay);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryTextColor,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.primaryColor,
      ),
      onTap: onTap,
    );
  }
}
