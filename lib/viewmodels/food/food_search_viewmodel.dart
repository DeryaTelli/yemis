import 'package:flutter/material.dart';
import '../../models/food/food_listing.dart';
import '../../models/food/food_sort_type.dart';
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

  FoodSortType _activeSortType = FoodSortType.none;
  FoodSortType get activeSortType => _activeSortType;

  List<FoodListing> _allListings = [];
  List<FoodListing> _filteredListings = [];
  List<FoodListing> get filteredListings => _filteredListings;

  // ─── Actions ──────────────────────────────────────────

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allListings = await _service.getFeaturedListings();
      _applyFilterAndSort();
    } catch (_) {
      // Hata yönetimi eklenebilir
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
  void selectSortType(FoodSortType type) {
    _activeSortType = (_activeSortType == type) ? FoodSortType.none : type;
    _applyFilterAndSort();
  }

  /// Filtreyi ve sıralamayı uygular, ardından ViewModel'i bilgilendirir.
  void _applyFilterAndSort() {
    // 1. Arama filtresi
    List<FoodListing> result;
    if (_searchQuery.isEmpty) {
      result = List.from(_allListings);
    } else {
      final q = _searchQuery.toLowerCase();
      result = _allListings.where((l) {
        return l.title.toLowerCase().contains(q) ||
            l.shopName.toLowerCase().contains(q) ||
            l.category.toLowerCase().contains(q);
      }).toList();
    }

    // 2. Sıralama
    switch (_activeSortType) {
      case FoodSortType.ratingAsc:
        result.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case FoodSortType.priceAsc:
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case FoodSortType.distanceAsc:
        result.sort((a, b) {
          final da = _parseDistanceMeters(a.location);
          final db = _parseDistanceMeters(b.location);
          return da.compareTo(db);
        });
        break;
      case FoodSortType.none:
        break;
    }

    _filteredListings = result;
    notifyListeners();
  }

  /// Konum metninden mesafeyi metreye çevirir.
  /// Örnek: "679m | Murat Pastanesi" → 679
  ///         "1.2km | Bodrum Fırın"  → 1200
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
    return double.maxFinite; // Bilinmeyen → sona koy
  }

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  /// Favori Toggle
  void toggleFavorite(String id) {
    _service.toggleFavorite(id);

    final index = _allListings.indexWhere((l) => l.id == id);
    if (index != -1) {
      _allListings = List.of(_allListings)
        ..[index] = _allListings[index].copyWith(
          isFavorite: !_allListings[index].isFavorite,
        );
      _applyFilterAndSort();
    }
  }

  /// MVVM: Alt navigasyon rotalarını ViewModel sağlar
  String? getBottomNavRoute(int index) {
    switch (index) {
      case 0:
        return AppRoutes.home;
      case 1:
        return AppRoutes.foodSearch;
      case 2:
        return AppRoutes.home;
      case 3:
        return AppRoutes.foodFavorites;
      case 4:
        return AppRoutes.foodProfile;
      default:
        return null;
    }
  }
}
