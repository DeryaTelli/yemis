import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:yemis/services/auth/user_session.dart';
import 'package:yemis/widgets/business/co2_card.dart';
import 'package:yemis/widgets/business/info_card.dart';
import 'package:yemis/widgets/business/order_button.dart';
import 'package:yemis/widgets/business/weekly_sales_card.dart';
import '../../models/app_module_type.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../viewmodels/home/business_home_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/home_app_bar.dart';
import '../../utils/routes/app_routes.dart';

/// İşletme ana sayfası
class BusinessHomeView extends StatelessWidget {
  const BusinessHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          BusinessHomeViewModel(userSession: ctx.read<UserSession>()),
      child: Consumer<BusinessHomeViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            appBar: HomeAppBar(
              title: vm.appBarTitle,
              backgroundColor: vm.appBarColor,
              isLocationTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Haftalık Satış Özeti ────────────────────
                  WeeklySalesCard(salesData: vm.weeklySales),
                  const SizedBox(height: 16),

                  // ── Eklenen / Satılan Siparişler ─────────────
                  Row(
                    children: [
                      Expanded(
                        child: OrderButton(
                          label: LocaleKeys.businessHome_addedOrders.tr(),
                          imagePath: 'assets/businessIcon/addOrder.png',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OrderButton(
                          label: LocaleKeys.businessHome_soldOrders.tr(),
                          imagePath: 'assets/businessIcon/sellOrder.png',
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Raporlar ────────────────────────────────
                  InfoCard(
                    imagePath: 'assets/businessIcon/rapor.png',
                    title: LocaleKeys.businessHome_reportsTitle.tr(),
                    description: LocaleKeys.businessHome_reportsDescription
                        .tr(),
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),

                  // ── CO₂ Etkisi ──────────────────────────────
                  Co2Card(co2Percent: vm.co2SavedPercent),
                  const SizedBox(height: 24),

                  // ── Sipariş Ekle butonu ──────────────────────
                  CustomButton(
                    text: LocaleKeys.businessHome_addOrderButton.tr(),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.businessAddOrder,
                      );
                    },
                    width: double.infinity,
                    height: 52,
                    borderRadius: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/businessIcon/add.png',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          LocaleKeys.businessHome_addOrderButton.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            bottomNavigationBar: AppBottomNavBar(
              selectedIndex: vm.selectedIndex,
              onItemSelected: (index) {
                final route = vm.getBottomNavRoute(index);
                if (route != null) {
                  if (index == 2) {
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        route,
                        (r) => false,
                      );
                    }
                  } else if (ModalRoute.of(context)?.settings.name != route) {
                    Navigator.pushReplacementNamed(context, route);
                  }
                } else {
                  vm.onTabSelected(index);
                }
              },
              moduleType: AppModuleType.business,
            ),
          );
        },
      ),
    );
  }
}
