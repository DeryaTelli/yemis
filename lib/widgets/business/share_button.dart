import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:yemis/utils/locale_keys.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../viewmodels/business/business_add_order_viewmodel.dart';

import '../../widgets/common/success_dialog_custom.dart';

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
                SuccessDialogCustom.show(
                  context,
                  title: LocaleKeys.common_success.tr(),
                  message: LocaleKeys.businessAddOrder_successMessage.tr(),
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
