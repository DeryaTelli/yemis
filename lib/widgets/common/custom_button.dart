import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/theme/text_styles_custom.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback onPressed;
  final bool isOutlined;
  final double? width;
  final double height;
  final TextStyle? textStyle;
  final bool isLoading;
  final double borderRadius;
  final Color? backgroundColor;
  final LinearGradient? gradient;

  const CustomButton({
    super.key,
    this.text,
    this.child,
    required this.onPressed,
    this.isOutlined = false,
    this.width,
    this.height = 50.0,
    this.textStyle,
    this.isLoading = false,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.gradient,
  }) : assert(text != null || child != null, 'Either text or child must be provided');

  @override
  Widget build(BuildContext context) {
   
    final Color shadowColor = (gradient == AppColors.volunteerBackgroundGradient)
        ? AppColors.volunteerColor.withValues(alpha: 0.3)
        : (backgroundColor == AppColors.volunteerColor)
            ? AppColors.volunteerColor.withValues(alpha: 0.3)
            : AppColors.primaryColor.withValues(alpha: 0.3);

    final decoration = isOutlined
        ? BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: backgroundColor ?? AppColors.primaryBorderColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          )
        : BoxDecoration(
            color: backgroundColor,
            gradient: backgroundColor == null
                ? (gradient ?? AppColors.primaryButtonGradient)
                : null,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: (gradient == AppColors.volunteerBackgroundGradient) ? 14 : 10,
                offset: (gradient == AppColors.volunteerBackgroundGradient) ? const Offset(0, 5) : const Offset(0, 4),
              ),
            ],
          );

    final defaultTextStyle = isOutlined
        ? (backgroundColor != null
            ? CustomTextStyles.bold16DarkGreyCompact.copyWith(color: backgroundColor)
            : CustomTextStyles.bold16DarkGreyCompact)
        : CustomTextStyles.bold17White; 
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          width: width, 
          height: height,
          decoration: decoration,
          child: Center(
            child: child ??
                Text(
                  text!,
                  style: textStyle ?? defaultTextStyle,
                  textAlign: TextAlign.center,
                ),
          ),
        ),
      ),
    );
  }
}
