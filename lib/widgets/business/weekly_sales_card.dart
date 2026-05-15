import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import 'bar_chart.dart';

class WeeklySalesCard extends StatelessWidget {
  final List<double> salesData;
  final String? imageUrl;

  const WeeklySalesCard({
    super.key,
    required this.salesData,
    this.imageUrl,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKeys.businessHome_weeklySalesTitle.tr(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B1B1B),
                ),
              ),
              // Mascot character or Business Profile Image
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.store_rounded,
                            color: AppColors.primaryColor,
                            size: 24,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.store_rounded,
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: BarChart(
              data: salesData, 
              days: context.locale.languageCode == 'en' 
                ? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                : const ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cts', 'Paz'],
            ),
          ),
        ],
      ),
    );
  }
}
