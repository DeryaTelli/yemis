import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/models/volunteer/volunteer_listing.dart';
import 'package:yemis/services/auth/user_session.dart';
import 'package:yemis/services/volunteer/i_volunteer_service.dart';
import 'package:yemis/models/app_module_type.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:yemis/viewmodels/home/volunteer_home_viewmodel.dart';
import 'package:yemis/utils/theme/app_theme.dart';
import 'package:yemis/widgets/common/app_bottom_nav_bar.dart';
import 'package:yemis/widgets/common/home_app_bar.dart';
import 'package:yemis/widgets/volunteer/volunteer_listing_section.dart';
import 'package:yemis/widgets/volunteer/volunteer_map_section.dart';
import 'package:yemis/widgets/volunteer/volunteer_search_bar.dart';
import 'package:yemis/widgets/common/loading_overlay.dart';
import 'package:yemis/widgets/common/draggable_chat_head.dart';

/// Gönüllü ana sayfası — API entegrasyonu ile ilanları çeker.
class VolunteerHomeView extends StatelessWidget {
  const VolunteerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeFor(AppSection.volunteer),
      child: ChangeNotifierProvider(
        create: (ctx) => VolunteerHomeViewModel(
          userSession: ctx.read<UserSession>(),
          volunteerService: ctx.read<IVolunteerService>(),
        ),
        child: const _VolunteerHomeBody(),
      ),
    );
  }
}

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
      showChatHead: true,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: HomeAppBar(
          title: vm.appBarTitle,
          backgroundColor: vm.appBarColor,
          isLocationTitle: true,
          moduleType: AppModuleType.volunteer,
        ),
        body: RefreshIndicator(
          onRefresh: vm.init,
          color: vm.appBarColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                // ── Arama Barı ─────────────────────────────
                VolunteerSearchBar(
                  controller: _searchController,
                  onChanged: vm.onSearchChanged,
                ),
                const SizedBox(height: 20),

                // ── Harita Alanı ────────────────────────────
                VolunteerMapSection(
                  listings: vm.filteredListings,
                  userLat: vm.userLat,
                  userLng: vm.userLng,
                ),
                const SizedBox(height: 24),

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
          moduleType: AppModuleType.volunteer,
        ),
      ),
    );
  }
}
