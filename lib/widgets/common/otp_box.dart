import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/theme/text_styles_custom.dart';

/// 4 haneli OTP giriş kutularından tek bir hane.
///
/// [controller] ve [focusNode] dışarıdan (ViewModel'den) sağlanır.
/// [onChanged] → bir sonraki haneye geç.
/// [onBackspace] → önceki haneye dön.
class OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const OtpBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 60,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onBackspace();
          }
        },
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          style: CustomTextStyles.extraBold20DarkGrey,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.hintTextColor,
                width: 1.5,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.primaryColor,
                width: 2.0,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
