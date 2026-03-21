import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../viewmodels/business/business_add_order_viewmodel.dart';

class LocationButton extends StatelessWidget {
  const LocationButton({super.key, required this.vm});
  final BusinessAddOrderViewModel vm;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => vm.pickLocation(context),
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primaryColor,
            width: 1.3,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          vm.hasLocation ? vm.locationAddress : LocaleKeys.businessAddOrder_locationButton.tr(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryTextColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
