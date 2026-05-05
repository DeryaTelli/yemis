import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';

class SuccessDialogCustom extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onConfirm;

  const SuccessDialogCustom({
    super.key,
    this.title = 'Başarılı',
    required this.message,
    this.onConfirm,
  });

  static void show(
    BuildContext context, {
    String title = 'Başarılı',
    required String message,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SuccessDialogCustom(
        title: title,
        message: message,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 ÜST: Lottie + Başlık
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/success.json',
                height: 120,
                repeat: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: CustomTextStyles.orelegaOne32Primary.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              message,
              style: CustomTextStyles.semiBold16DarkGreyCompact,
            ),
          ),

          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm?.call();
              },
              child: Text(
                'Tamam',
                style: CustomTextStyles.semiBold16Primary.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
