import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../utils/routes/app_routes.dart';
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
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (listing.originalPrice != null &&
                  listing.originalPrice! > listing.price)
                Text(
                  '${listing.originalPrice!.toInt()} TL',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.hintTextColor,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColors.primaryTextColor,
                    decorationThickness: 1.5,
                  ),
                ),
              Text(
                '${listing.price.toInt()} TL',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryTextColor,
                ),
              ),
            ],
          ),
          const Spacer(),

          // Rezerve Et → rezervasyon ekranına yönlendir
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.foodReserve,
                arguments: listing,
              );
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
