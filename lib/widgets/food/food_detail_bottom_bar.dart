import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../viewmodels/food/food_detail_viewmodel.dart';

class FoodDetailBottomBar extends StatelessWidget {
  const FoodDetailBottomBar({super.key, required this.vm});

  final FoodDetailViewModel vm;

  @override
  Widget build(BuildContext context) {
    final listing = vm.listing;
    if (listing == null) return const SizedBox();

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Fiyat
          Text(
            '${listing.price.toInt()} TL',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryTextColor,
            ),
          ),
          const Spacer(),

          // Rezerve Et
          GestureDetector(
            onTap: () async {
              await vm.reserve();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${listing.title} için rezervasyon alındı!',
                    ),
                    backgroundColor: AppColors.primaryColor,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryButtonGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                LocaleKeys.foodDetail_reserveButton.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
