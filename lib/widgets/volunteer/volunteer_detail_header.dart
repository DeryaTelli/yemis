import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/volunteer/volunteer_detail_viewmodel.dart';

class VolunteerDetailHeader extends StatelessWidget {
  const VolunteerDetailHeader({super.key, required this.listing});

  final VolunteerListing listing;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VolunteerDetailViewModel>();

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
                // İlan Adı
                Text(
                  "${listing.userName} - ${listing.title}",
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
                        color: AppColors.volunteerColor, size: 14),
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

                // Mesafe + Kullanıcı
                Row(
                  children: [
                    const Icon(Icons.ios_share_outlined, // Placeholder for typical location icon if needed, but let's use location 
                        color: AppColors.volunteerColor, size: 14),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        "${vm.distanceText} | ${listing.userName}",
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
              color: AppColors.volunteerColor,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
