import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../viewmodels/business/business_add_order_viewmodel.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({super.key, required this.vm, this.onSuccess});
  final BusinessAddOrderViewModel vm;
  final VoidCallback? onSuccess;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: vm.isSubmitting
          ? null
          : () async {
              final ok = await vm.submit();
              if (ok && context.mounted) {
                if (onSuccess != null) onSuccess!();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(LocaleKeys.businessAddOrder_successMessage.tr()),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: AppColors.primaryButtonGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          LocaleKeys.businessAddOrder_shareButton.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
