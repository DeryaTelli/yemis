import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';

class PriceField extends StatelessWidget {
  const PriceField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText,
  });
  final TextEditingController controller;
  final void Function(String) onChanged;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 40,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryTextColor,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w400),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          suffix: const Text(
            'TL',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryTextColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryColor),
          ),
        ),
      ),
    );
  }
}
