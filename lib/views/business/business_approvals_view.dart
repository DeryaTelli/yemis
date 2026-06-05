import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/services/volunteer/i_volunteer_service.dart';
import 'package:yemis/widgets/business/reservation_card.dart';
import '../../models/app_module_type.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../viewmodels/business/business_approvals_viewmodel.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';

class BusinessApprovalsView extends StatelessWidget {
  const BusinessApprovalsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => BusinessApprovalsViewModel(
        volunteerService: ctx.read<IVolunteerService>(),
      ),
      child: Consumer<BusinessApprovalsViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(LocaleKeys.businessApprovals_title.tr()),
            ),
            body: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  )
                : vm.reservations.isEmpty
                ? Center(
                    child: Text(
                      vm.error ?? LocaleKeys.businessApprovals_noPending.tr(),
                      style: TextStyle(fontSize: 15, color: Color(0xFF888888)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.reservations.length,
                    itemBuilder: (context, i) {
                      final r = vm.reservations[i];
                      return ReservationCard(
                        reservation: r,
                        isApproved: vm.isApproved(r.id),
                        isRejected: vm.isRejected(r.id),
                        onApprove: () => vm.approve(r.id),
                        onReject: () => vm.reject(r.id),
                      );
                    },
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
