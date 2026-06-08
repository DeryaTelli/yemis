import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/utils/constants/app_colors.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:yemis/viewmodels/business/business_reports_viewmodel.dart';
import 'package:yemis/widgets/business/weekly_sales_card.dart';
import 'package:yemis/widgets/common/loading_overlay.dart';
import '../../models/app_module_type.dart';
import '../../services/auth/user_session.dart';

class BusinessReportsView extends StatelessWidget {
  const BusinessReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessReportsViewModel>(
      builder: (context, vm, child) {
        final stats = vm.stats;
        final profileImageUrl = context
            .watch<UserSession>()
            .currentUser
            ?.imageUrl;

        return LoadingOverlay(
          isLoading: vm.isLoading,
          moduleType: AppModuleType.business,
          child: Scaffold(
            backgroundColor: const Color(0xFFFFFBF6),
            appBar: AppBar(title: Text(LocaleKeys.businessReports_title.tr())),
            body: RefreshIndicator(
              color: AppColors.primaryColor,
              onRefresh: vm.fetchStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: stats == null
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Text(
                            LocaleKeys.businessReports_noData.tr(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Weekly Sales summary chart ---
                          WeeklySalesCard(
                            salesData: stats.weeklySales,
                            imageUrl: profileImageUrl,
                          ),
                          const SizedBox(height: 16),

                          // --- Top KPIs Grid ---
                          Row(
                            children: [
                              Expanded(
                                child: _buildKpiCard(
                                  title: LocaleKeys.businessReports_totalRevenue
                                      .tr(),
                                  value:
                                      "${stats.totalRevenue.toStringAsFixed(2)} TL",
                                  icon: Icons.payments_rounded,
                                  startColor: const Color(0xFFFFFFFF),
                                  endColor: const Color(0xFFFFF8EE),
                                  textColor: const Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildKpiCard(
                                  title: LocaleKeys.businessReports_mealsSaved
                                      .tr(),
                                  value: "${stats.mealsSaved} ${' adet'}",
                                  icon: Icons.restaurant_rounded,
                                  startColor: const Color(0xFFFFF7EC),
                                  endColor: const Color(0xFFFFE1B8),
                                  textColor: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // --- STR & Business Rating Card ---
                          _buildStrAndRatingCard(stats),
                          const SizedBox(height: 16),

                          // --- Environmental impact summary ---
                          _buildEnvironmentalImpactCard(stats),
                          const SizedBox(height: 16),

                          // --- Operational Listings summary ---
                          _buildListingPerformanceSummary(stats),
                          const SizedBox(height: 24),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color startColor,
    required Color endColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.28),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: textColor.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: textColor, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrAndRatingCard(dynamic stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor.withValues(alpha: 0.07),
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: (stats.sellThroughRate / 100).clamp(0.0, 1.0),
                          backgroundColor: AppColors.primaryColor.withValues(
                            alpha: 0.13,
                          ),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor,
                          ),
                          strokeWidth: 5,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "${stats.sellThroughRate.toStringAsFixed(0)}%",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryColor,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.businessReports_sellThroughRate.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'businessReports.soldTotal'.tr(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade200),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats.rating > 0
                          ? stats.rating.toStringAsFixed(1)
                          : "0.0",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF222222),
                      ),
                    ),
                    Text(
                      LocaleKeys.businessReports_rating.tr(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalImpactCard(dynamic stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.22),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                LocaleKeys.businessReports_environmentalImpact.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.businessReports_co2Saved.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${stats.co2SavedKg.toStringAsFixed(1)} kg",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.businessReports_wastePrevented.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${stats.wastePreventedKg.toStringAsFixed(1)} kg",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListingPerformanceSummary(dynamic stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.businessReports_performanceSummary.tr(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 16),
          _buildPerformanceRow(
            label: LocaleKeys.businessReports_totalOrders.tr(),
            value: "${stats.totalOrders} ${' adet'}",
            icon: Icons.shopping_bag_outlined,
            color: AppColors.primaryColor,
          ),
          const Divider(height: 20, thickness: 0.8),
          _buildPerformanceRow(
            label: LocaleKeys.businessReports_activeListings.tr(),
            value: "${stats.activeBags} ${' adet'}",
            icon: Icons.local_offer_outlined,
            color: Colors.green,
          ),
          const Divider(height: 20, thickness: 0.8),
          _buildPerformanceRow(
            label: LocaleKeys.businessReports_soldOutListings.tr(),
            value: "${stats.soldOutBags} ${' adet'}",
            icon: Icons.check_circle_outline_rounded,
            color: Colors.blue,
          ),
          const Divider(height: 20, thickness: 0.8),
          _buildPerformanceRow(
            label: LocaleKeys.businessReports_unsoldListings.tr(),
            value: "${stats.unsoldItems} ${' adet'}",
            icon: Icons.history_rounded,
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: color.withValues(alpha: 0.18)),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF444444),
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF222222),
          ),
        ),
      ],
    );
  }
}
