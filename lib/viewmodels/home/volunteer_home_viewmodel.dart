import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:yemis/models/volunteer/volunteer_listing.dart';
import 'package:yemis/services/auth/user_session.dart';
import 'package:yemis/services/volunteer/i_volunteer_service.dart';
import 'package:yemis/utils/routes/app_routes.dart';

/// VolunteerHome ekranının ViewModel'i.
class VolunteerHomeViewModel extends ChangeNotifier {
  VolunteerHomeViewModel({
    required UserSession userSession,
    required IVolunteerService volunteerService,
  })  : _userSession = userSession,
        _service = volunteerService {
    _userSession.addListener(_onUserSessionChanged);
    init();
  }

  final IVolunteerService _service;
  final UserSession _userSession;

  // ─── State ────────────────────────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<VolunteerListing> _allListings = [];
  List<VolunteerListing> get listings => filteredListings;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  String get appBarTitle {
    final addr = _userSession.currentAddress;
    if (addr != null && addr.isNotEmpty) return addr;
    return LocaleKeys.common_selectLocation.tr();
  }

  Color get appBarColor => const Color(0xFF22B05A); // AppColors.volunteerColor

  // ─── Init ─────────────────────────────────────────────

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await _service.getFeaturedListings(
        lat: _userSession.currentLat,
        lng: _userSession.currentLng,
        radius: 10000,
      );

      var sortedListings = List<VolunteerListing>.from(results);

      // Konuma göre sırala (Eğer kullanıcı konumu varsa)
      if (_userSession.currentLat != null && _userSession.currentLng != null) {
        sortedListings.sort((a, b) {
          if (a.latitude == null || a.longitude == null) return 1;
          if (b.latitude == null || b.longitude == null) return -1;

          final distA = (a.latitude! - _userSession.currentLat!) * (a.latitude! - _userSession.currentLat!) +
                        (a.longitude! - _userSession.currentLng!) * (a.longitude! - _userSession.currentLng!);
          final distB = (b.latitude! - _userSession.currentLat!) * (b.latitude! - _userSession.currentLat!) +
                        (b.longitude! - _userSession.currentLng!) * (b.longitude! - _userSession.currentLng!);
          return distA.compareTo(distB);
        });
      }

      // İlanlara bölüm ataması yapalım
      _allListings = sortedListings.asMap().entries.map((entry) {
        final index = entry.key;
        final listing = entry.value;
        
        // İlk 2 ilan yakında, kalanlar popüler
        return listing.copyWith(
          section: index < 2 ? VolunteerSection.nearYou : VolunteerSection.todayPopular,
        );
      }).toList();

    } catch (e) {
      debugPrint('Error fetching home listings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _onUserSessionChanged() {
    // Konum değiştiyse yeniden çek
    init();
  }

  // ─── Arama ────────────────────────────────────────────

  void onSearchChanged(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ─── Filtrelenmiş İlanlar ─────────────────────────────

  List<VolunteerListing> get filteredListings {
    var list = _allListings;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((l) {
        return l.title.toLowerCase().contains(q) ||
            l.userName.toLowerCase().contains(q) ||
            l.location.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  // ─── Bottom Navigation ────────────────────────────────

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
    debugPrint("Volunteer Tab Selected: $index");
  }

  String? getBottomNavRoute(int index) {
    switch (index) {
      case 0:
        return AppRoutes.volunteerHome;
      case 2:
        return AppRoutes.home;
      case 1:
        return AppRoutes.volunteerSearch;
      case 3:
        return AppRoutes.volunteerAddListing;
      case 4:
        return AppRoutes.volunteerProfile;
      default:
        return null;
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _userSession.removeListener(_onUserSessionChanged);
    super.dispose();
  }
}

