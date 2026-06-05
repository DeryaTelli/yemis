import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../utils/theme/text_styles_custom.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.cancelText = 'Hayır',
    this.confirmText = 'Evet',
  });

  final String title;
  final String message;
  final String cancelText;
  final String confirmText;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String cancelText = 'Hayır',
    String confirmText = 'Evet',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => DeleteConfirmationDialog(
        title: title,
        message: message,
        cancelText: cancelText,
        confirmText: confirmText,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFFFDF5F2),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Lottie.asset(
                'assets/lottie/account_delete.json',
                width: 60,
                height: 60,
                repeat: true,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: CustomTextStyles.orelegaOne30Primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(message, style: CustomTextStyles.semiBold16Grey),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelText, style: CustomTextStyles.semiBold16Grey),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  confirmText,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
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
