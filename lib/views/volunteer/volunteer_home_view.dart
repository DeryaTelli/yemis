import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/models/volunteer/volunteer_listing.dart';
import '../../models/app_module_type.dart';
import '../../utils/locale_keys.dart';
import '../../viewmodels/home/volunteer_home_viewmodel.dart';
import '../../utils/theme/app_theme.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import '../../widgets/common/home_app_bar.dart';
import '../../widgets/volunteer/volunteer_listing_section.dart';
import '../../widgets/volunteer/volunteer_map_section.dart';
import '../../widgets/volunteer/volunteer_search_bar.dart';
import '../../widgets/common/loading_overlay.dart';

/// Gönüllü ana sayfası — tam MVVM ile uygulanmıştır.
class VolunteerHomeView extends StatelessWidget {
  const VolunteerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeFor(AppSection.volunteer),
      child: ChangeNotifierProvider(
        create: (_) => VolunteerHomeViewModel(),
        child: const _VolunteerHomeBody(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────
class _VolunteerHomeBody extends StatefulWidget {
  const _VolunteerHomeBody();

  @override
  State<_VolunteerHomeBody> createState() => _VolunteerHomeBodyState();
}

class _VolunteerHomeBodyState extends State<_VolunteerHomeBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VolunteerHomeViewModel>();

    return LoadingOverlay(
      isLoading: vm.isLoading,
      moduleType: AppModuleType.volunteer,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        // ─── AppBar ──────────────────────────────────
        appBar: HomeAppBar(
          title: vm.appBarTitle,
          backgroundColor: vm.appBarColor,
          isLocationTitle: true,
          moduleType: AppModuleType.volunteer,
        ),

        // ─── Body ────────────────────────────────────
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Arama Barı ─────────────────────────────
              VolunteerSearchBar(
                controller: _searchController,
                onChanged: vm.onSearchChanged,
              ),
              const SizedBox(height: 16),

              // ── Açık Yeşil/Yeşil Degrade Çizgi (Opsiyonel görsel şıklık için)
              // Tasarımda arama ile harita arası boşluk var

              // ── Harita Alanı ────────────────────────────
              VolunteerMapSection(listings: vm.filteredListings),
              const SizedBox(height: 20),

              // ── Sana Yakın Yerler ───────────────────────
              VolunteerListingSection(
                title: LocaleKeys.volunteerHome_nearbyPlaces.tr(),
                section: VolunteerSection.nearYou,
              ),
              const SizedBox(height: 24),

              // ── Bugün Popüler Olanlar ───────────────────
              VolunteerListingSection(
                title: LocaleKeys.volunteerHome_todayPopular.tr(),
                section: VolunteerSection.todayPopular,
              ),
              const SizedBox(height: 32),
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
                  Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
                }
              } else if (ModalRoute.of(context)?.settings.name != route) {
                Navigator.pushReplacementNamed(context, route);
              }
            } else {
              vm.onTabSelected(index);
            }
          },
          moduleType: AppModuleType.volunteer,
        ),
      ),
    );
  }
}
