import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/models/app_module_type.dart';
import 'package:yemis/models/volunteer/volunteer_listing.dart';
import 'package:yemis/services/auth/user_session.dart';
import 'package:yemis/services/volunteer/i_volunteer_service.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:yemis/viewmodels/home/volunteer_home_viewmodel.dart';
import 'package:yemis/widgets/common/app_bottom_nav_bar.dart';
import 'package:yemis/widgets/common/home_app_bar.dart';
import 'package:yemis/widgets/volunteer/volunteer_listing_section.dart';
import 'package:yemis/widgets/volunteer/volunteer_map_section.dart';
import 'package:yemis/widgets/volunteer/volunteer_search_bar.dart';
import 'package:yemis/widgets/common/loading_overlay.dart';

class VolunteerHomeView extends StatelessWidget {
  const VolunteerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => VolunteerHomeViewModel(
        userSession: ctx.read<UserSession>(),
        volunteerService: ctx.read<IVolunteerService>(),
      ),
      child: const _VolunteerHomeBody(),
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
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                VolunteerSearchBar(
                  controller: _searchController,
                  onChanged: vm.onSearchChanged,
                ),
                const SizedBox(height: 20),
                if (vm.filteredListings.isNotEmpty) ...[
                  VolunteerMapSection(listings: vm.filteredListings),
                  const SizedBox(height: 24),
                ],
                VolunteerListingSection(
                  title: LocaleKeys.volunteerHome_nearbyPlaces.tr(),
                  section: VolunteerSection.nearYou,
                ),
                const SizedBox(height: 24),
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
          onItemSelected: vm.onTabSelected,
          moduleType: AppModuleType.volunteer,
        ),
      ),
    );
  }
}
