import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../services/volunteer/i_volunteer_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/volunteer/volunteer_detail_viewmodel.dart';
import '../../widgets/volunteer/volunteer_detail_bottom_bar.dart';
import '../../widgets/volunteer/volunteer_detail_header.dart';
import '../../widgets/volunteer/volunteer_detail_hero_image.dart';
import '../../widgets/volunteer/volunteer_detail_tab_bar.dart';
import '../../widgets/volunteer/volunteer_order_tab.dart';
import '../../widgets/volunteer/volunteer_review_tab.dart';

import '../../widgets/common/loading_overlay.dart';
import '../../models/app_module_type.dart';

/// Gönüllü ilan detay ekranı.
class VolunteerDetailView extends StatelessWidget {
  const VolunteerDetailView({super.key, required this.listing});

  final VolunteerListing listing;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VolunteerDetailViewModel(
        service: context.read<IVolunteerService>(),
        listingId: listing.id,
      )..init(),
      child: _VolunteerDetailBody(listing: listing),
    );
  }
}

// ─────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────
class _VolunteerDetailBody extends StatelessWidget {
  const _VolunteerDetailBody({required this.listing});

  final VolunteerListing listing;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VolunteerDetailViewModel>();

    return LoadingOverlay(
      isLoading: vm.isLoading,
      moduleType: AppModuleType.volunteer,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // ── Ana İçerik ────────────────────────────
            Column(
              children: [
                // Hero Resim
                VolunteerDetailHeroImage(listing: listing),

                // Başlık Alanı
                VolunteerDetailHeader(listing: listing),

                // Tab Bar
                VolunteerDetailTabBar(vm: vm),

                // Tab İçeriği
                Expanded(
                  child: vm.selectedTab == 0
                      ? const VolunteerOrderTab()
                      : const VolunteerReviewTab(),
                ),
              ],
            ),

            // ── Alt Ücretsiz + Gönüllü Ol Bar ──────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VolunteerDetailBottomBar(vm: vm),
            ),
          ],
        ),
      ),
    );
  }
}
