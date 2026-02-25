import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food/food_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/food/food_detail_viewmodel.dart';
import '../../views/location/navigation_view.dart';

class FoodDetailHeader extends StatelessWidget {
  const FoodDetailHeader({super.key, required this.listing});

  final FoodListing listing;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FoodDetailViewModel>();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ürün Adı
                Text(
                  listing.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 6),

                // Saat aralığı (Dinamik: Bugün Al vb.)
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        color: AppColors.primaryColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      vm.deliveryText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.hintTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Mesafe + Mağaza (Dinamik mesafe)
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.primaryColor, size: 14),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        "${vm.distanceText} | ${listing.shopName}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.hintTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Paylaş ikonu
          IconButton(
            onPressed: () {
              // TODO: Share
            },
            icon: const Icon(
              Icons.ios_share_rounded,
              color: AppColors.primaryColor,
              size: 22,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
