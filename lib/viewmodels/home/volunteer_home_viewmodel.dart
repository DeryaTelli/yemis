import 'package:flutter/material.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../services/auth/user_session.dart';
import '../../services/volunteer/mock_volunteer_service.dart';
import '../../utils/routes/app_routes.dart';

/// VolunteerHome ekranının ViewModel'i.
class VolunteerHomeViewModel extends ChangeNotifier {
  VolunteerHomeViewModel({required UserSession userSession}) : _userSession = userSession {
    _userSession.addListener(_onUserSessionChanged);
    init();
  }

  final MockVolunteerService _service = MockVolunteerService();
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
    return 'Konum Seçiniz';
  }

  Color get appBarColor => const Color(0xFF22B05A); // AppColors.volunteerColor

  // ─── Init ─────────────────────────────────────────────

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _service.getFeaturedListings(),
    ]);

    _allListings = results[0] as List<VolunteerListing>;

    _isLoading = false;
    notifyListeners();
  }

  void _onUserSessionChanged() {
    notifyListeners();
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
  void dispose() {
    _userSession.removeListener(_onUserSessionChanged);
    super.dispose();
  }
}
