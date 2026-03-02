import 'package:flutter/material.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../services/volunteer/mock_volunteer_service.dart';
import '../../utils/routes/app_routes.dart';

/// VolunteerHome ekranının ViewModel'i.
class VolunteerHomeViewModel extends ChangeNotifier {
  VolunteerHomeViewModel() {
    init();
  }

  final MockVolunteerService _service = MockVolunteerService();

  // ─── State ────────────────────────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _locationName = '';
  String get locationName => _locationName;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<VolunteerListing> _allListings = [];
  List<VolunteerListing> get listings => filteredListings;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  String get appBarTitle => _locationName.isEmpty ? 'Konum yükleniyor…' : _locationName;
  Color get appBarColor => const Color(0xFF22B05A); // AppColors.volunteerColor

  // ─── Init ─────────────────────────────────────────────

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _service.getUserLocationName(),
      _service.getFeaturedListings(),
    ]);

    _locationName = results[0] as String;
    _allListings = results[1] as List<VolunteerListing>;

    _isLoading = false;
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

    // Metin filtresi
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
      case 0: return AppRoutes.volunteerHome;
      case 1: return AppRoutes.volunteerSearch;
      case 2: return AppRoutes.home;
      case 3: return AppRoutes.volunteerAddListing;
      case 4: return AppRoutes.volunteerProfile;
      default: return null;
    }
  }
}
