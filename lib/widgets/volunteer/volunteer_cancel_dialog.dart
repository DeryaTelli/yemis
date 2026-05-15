import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';

class VolunteerCancelDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const VolunteerCancelDialog({super.key, required this.onConfirm});

  static void show(BuildContext context, {required VoidCallback onConfirm}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) =>
          VolunteerCancelDialog(onConfirm: onConfirm),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(opacity: anim1.value, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 ÜST: Lottie + Başlık (Yan Yana)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/cancel.json',
                height: 70,
                repeat: false,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  LocaleKeys.taskTracking_buttonCancel.tr(),
                  style: CustomTextStyles.orelegaOne28DarkGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              LocaleKeys.volunteerCancelDialog_confirm.tr(),
              style: CustomTextStyles.semiBold14DarkGrey,
            ),
          ),

          const SizedBox(height: 12),

          /// 🔥 ALT: Butonlar (Sağa Dayalı TextButton)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Vazgeç', style: CustomTextStyles.semiBold16Grey),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                child: Text(
                  'Evet',
                  style: CustomTextStyles.semiBold16Primary.copyWith(
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
