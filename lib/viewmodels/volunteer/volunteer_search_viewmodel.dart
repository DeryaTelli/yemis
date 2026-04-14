import 'package:flutter/material.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../models/volunteer/volunteer_sort_type.dart';
import '../../services/volunteer/i_volunteer_service.dart';

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

  VolunteerSortType _activeSortType = VolunteerSortType.none;
  VolunteerSortType get activeSortType => _activeSortType;

  List<VolunteerListing> _allListings = [];
  List<VolunteerListing> _filteredListings = [];
  List<VolunteerListing> get filteredListings => _filteredListings;

  // ─── Actions ──────────────────────────────────────────

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allListings = await _service.getFeaturedListings();
      _applyFilterAndSort();
    } catch (_) {
      // Hata yönetimi
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilterAndSort();
  }

  void toggleViewMode(bool isMap) {
    if (_isMapView == isMap) return;
    _isMapView = isMap;
    notifyListeners();
  }

  /// Sıralama türünü seçer; aynı türe tekrar basılırsa sıfırlar.
  void selectSortType(VolunteerSortType type) {
    _activeSortType = (_activeSortType == type) ? VolunteerSortType.none : type;
    _applyFilterAndSort();
  }

  void _applyFilterAndSort() {
    // 1. Arama filtresi
    List<VolunteerListing> result;
    if (_searchQuery.isEmpty) {
      result = List.from(_allListings);
    } else {
      final q = _searchQuery.toLowerCase();
      result = _allListings.where((l) {
        return l.title.toLowerCase().contains(q) ||
            l.userName.toLowerCase().contains(q) ||
            l.location.toLowerCase().contains(q);
      }).toList();
    }

    // 2. Sıralama
    switch (_activeSortType) {
      case VolunteerSortType.ratingAsc:
        result.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case VolunteerSortType.distanceAsc:
        result.sort((a, b) {
          final da = _parseDistanceMeters(a.location);
          final db = _parseDistanceMeters(b.location);
          return da.compareTo(db);
        });
        break;
      case VolunteerSortType.none:
        break;
    }

    _filteredListings = result;
    notifyListeners();
  }

  /// Konum metninden mesafeyi metreye çevirir.
  double _parseDistanceMeters(String location) {
    final lower = location.toLowerCase();
    final kmMatch = RegExp(r'([\d.]+)\s*km').firstMatch(lower);
    if (kmMatch != null) {
      return (double.tryParse(kmMatch.group(1) ?? '0') ?? 0) * 1000;
    }
    final mMatch = RegExp(r'([\d.]+)\s*m').firstMatch(lower);
    if (mMatch != null) {
      return double.tryParse(mMatch.group(1) ?? '0') ?? 0;
    }
    return double.maxFinite;
  }

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }
}
