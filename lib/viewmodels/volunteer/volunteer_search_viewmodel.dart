import 'package:flutter/material.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../services/volunteer/i_volunteer_service.dart';
import '../../utils/routes/app_routes.dart';

/// Volunteer Arama sayfası için ViewModel.
class VolunteerSearchViewModel extends ChangeNotifier {
  VolunteerSearchViewModel({required IVolunteerService service}) : _service = service;

  final IVolunteerService _service;

  // ─── State ────────────────────────────────────────────

  int _selectedIndex = 1;
  int get selectedIndex => _selectedIndex;

  bool _isMapView = false;
  bool get isMapView => _isMapView;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<VolunteerListing> _allListings = [];
  List<VolunteerListing> _filteredListings = [];
  List<VolunteerListing> get filteredListings => _filteredListings;

  // ─── Actions ──────────────────────────────────────────

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allListings = await _service.getFeaturedListings();
      _applyFilter();
    } catch (_) {
      // Hata yönetimi
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  void toggleViewMode(bool isMap) {
    if (_isMapView == isMap) return;
    _isMapView = isMap;
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredListings = List.from(_allListings);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredListings = _allListings.where((l) {
        return l.title.toLowerCase().contains(q) ||
            l.userName.toLowerCase().contains(q) ||
            l.location.toLowerCase().contains(q);
      }).toList();
    }
    notifyListeners();
  }

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }
}
