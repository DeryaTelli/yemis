import 'package:flutter/material.dart';
import '../../models/food/food_listing.dart';
import '../../utils/constants/app_colors.dart';

class FoodDetailHeader extends StatelessWidget {
  const FoodDetailHeader({super.key, required this.listing});

  final FoodListing listing;

  @override
  Widget build(BuildContext context) {
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

                // Saat aralığı
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        color: AppColors.primaryColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      listing.timeRange,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.hintTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Mesafe + Mağaza
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.primaryColor, size: 14),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        listing.location,
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
