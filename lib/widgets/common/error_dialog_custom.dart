import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';

class ErrorDialogCustom extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onConfirm;

  const ErrorDialogCustom({
    super.key,
    this.title = 'Hata',
    required this.message,
    this.onConfirm,
  });

  static void show(
    BuildContext context, {
    String title = 'Hata',
    required String message,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ErrorDialogCustom(
        title: title,
        message: message,
        onConfirm: onConfirm,
      ),
    );
  }

  String _getReadableMessage(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('sunucu') ||
        lower.contains('server') ||
        lower.contains('general') ||
        lower.contains('bir hata oluştu')) {
      return 'Sunucu kaynaklı bir hata oluştu. Lütfen internet bağlantınızı kontrol ederek işlemi tekrar deneyin.';
    }

    return message;
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
                'assets/lottie/error.json',
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
              _getReadableMessage(message),
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
