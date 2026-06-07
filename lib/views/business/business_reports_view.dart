import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/utils/constants/app_colors.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:yemis/viewmodels/business/business_reports_viewmodel.dart';
import 'package:yemis/widgets/business/weekly_sales_card.dart';
import 'package:yemis/widgets/common/loading_overlay.dart';
import '../../models/app_module_type.dart';

class BusinessReportsView extends StatelessWidget {
  const BusinessReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessReportsViewModel>(
      builder: (context, vm, child) {
        final stats = vm.stats;

        return LoadingOverlay(
          isLoading: vm.isLoading,
          moduleType: AppModuleType.business,
          child: Scaffold(
            backgroundColor: const Color(0xFFFAFAFA),
            appBar: AppBar(
              title: Text(
                LocaleKeys.businessReports_title.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: RefreshIndicator(
              color: AppColors.primaryColor,
              onRefresh: vm.fetchStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: stats == null
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Text(
                            LocaleKeys.businessReports_noData.tr(),
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Weekly Sales summary chart ---
                          WeeklySalesCard(
                            salesData: stats.weeklySales,
                          ),
                          const SizedBox(height: 16),

                          // --- Top KPIs Grid ---
                          Row(
                            children: [
                              Expanded(
                                child: _buildKpiCard(
                                  title: LocaleKeys.businessReports_totalRevenue.tr(),
                                  value: "${stats.totalRevenue.toStringAsFixed(2)} TL",
                                  icon: Icons.account_balance_wallet_rounded,
                                  startColor: const Color(0xFFE8F5E9),
                                  endColor: const Color(0xFFC8E6C9),
                                  textColor: const Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildKpiCard(
                                  title: LocaleKeys.businessReports_mealsSaved.tr(),
                                  value: "${stats.mealsSaved} ${' adet'}",
                                  icon: Icons.eco_rounded,
                                  startColor: const Color(0xFFFFF3E0),
                                  endColor: const Color(0xFFFFE0B2),
                                  textColor: const Color(0xFFE65100),
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
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: endColor.withOpacity(0.3),
            blurRadius: 8,
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
              Icon(icon, color: textColor, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.8),
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: stats.sellThroughRate / 100,
                        backgroundColor: Colors.orange.shade50,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                        strokeWidth: 5,
                      ),
                      Text(
                        "${stats.sellThroughRate.toStringAsFixed(0)}%",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.orange,
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
                      const Text(
                        "Satılan / Toplam",
                        style: TextStyle(
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
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.shade200,
          ),
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
                      stats.rating > 0 ? stats.rating.toStringAsFixed(1) : "0.0",
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
        color: const Color(0xFFE8F5E9).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_rounded, color: Color(0xFF2E7D32), size: 22),
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
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
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
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
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
