import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/theme/text_styles_custom.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final TextStyle? hintStyle;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final double borderRadius;
  final Color? fillColor;
  final bool readOnly;
  final VoidCallback? onTap;
  final int? maxLines;
  final int? minLines;
  final EdgeInsetsGeometry? contentPadding;
  final bool hasShadow;
  final Color? borderColor;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final String? prefixText;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.hintStyle,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.borderRadius = 12.0,
    this.fillColor = Colors.white,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.minLines,
    this.contentPadding,
    this.hasShadow = false,
    this.borderColor,
    this.inputFormatters,
    this.maxLength,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: hasShadow
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              borderRadius: BorderRadius.circular(borderRadius),
            )
          : null,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: validator,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        minLines: minLines,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        style: CustomTextStyles.regular16DarkGrey, // Default text style
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintStyle ?? CustomTextStyles.semiBold16Grey, // Default hint style
          labelText: labelText,
          labelStyle: CustomTextStyles.regular16Grey,
          prefixIcon: prefixIcon,
          prefixText: prefixText,
          prefixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1B1B1B)),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: fillColor,
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor ?? AppColors.hintTextColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor ?? AppColors.hintTextColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
      ),
    );
  }
}
