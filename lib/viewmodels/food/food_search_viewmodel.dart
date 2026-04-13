import 'package:flutter/material.dart';
import '../../models/food/food_listing.dart';
import '../../services/food/i_food_service.dart';
import '../../utils/routes/app_routes.dart';

/// Food Arama sayfası için ViewModel.
class FoodSearchViewModel extends ChangeNotifier {
  FoodSearchViewModel({required IFoodService service}) : _service = service;

  final IFoodService _service;

  // ─── State ────────────────────────────────────────────

  int _selectedIndex = 1;
  int get selectedIndex => _selectedIndex;

  bool _isMapView = false;
  bool get isMapView => _isMapView;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<FoodListing> _allListings = [];
  List<FoodListing> _filteredListings = [];
  List<FoodListing> get filteredListings => _filteredListings;

  // ─── Actions ──────────────────────────────────────────

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allListings = await _service.getFeaturedListings();
      _applyFilter();
    } catch (_) {
      // Hata yönetimi eklenebilir
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
            l.shopName.toLowerCase().contains(q) ||
            l.category.toLowerCase().contains(q);
      }).toList();
    }
    notifyListeners();
  }

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  /// Favori Toggle
  void toggleFavorite(String id) {
    _service.toggleFavorite(id);
    
    // Tüm listeyi ve filtrelenmiş listeyi güncelle
    final index = _allListings.indexWhere((l) => l.id == id);
    if (index != -1) {
      _allListings = List.of(_allListings)
        ..[index] = _allListings[index].copyWith(
          isFavorite: !_allListings[index].isFavorite,
        );
      _applyFilter();
    }
  }

  /// MVVM: Alt navigasyon rotalarını ViewModel sağlar
  String? getBottomNavRoute(int index) {
    switch (index) {
      case 0: return AppRoutes.foodHome;
      case 1: return AppRoutes.foodSearch;
      case 2: return AppRoutes.home;
      case 3: return AppRoutes.foodFavorites;
      case 4: return AppRoutes.foodProfile;
      default: return null;
    }
  }
}
