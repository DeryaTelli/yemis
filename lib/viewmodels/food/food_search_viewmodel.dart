import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../models/food/food_listing.dart';
import '../../models/food/food_sort_type.dart';
import '../../services/food/i_food_service.dart';
import '../../services/auth/user_session.dart';
import '../../utils/routes/app_routes.dart';

/// Food Arama sayfası için ViewModel.
class FoodSearchViewModel extends ChangeNotifier {
  FoodSearchViewModel({
    required IFoodService service,
    required UserSession userSession,
  }) : _service = service,
       _userSession = userSession;

  final IFoodService _service;
  final UserSession _userSession;

  // ─── State ────────────────────────────────────────────

  int _selectedIndex = 1;
  int get selectedIndex => _selectedIndex;

  bool _isMapView = false;
  bool get isMapView => _isMapView;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  LatLng? get userLocation {
    if (_userSession.currentLat != null && _userSession.currentLng != null) {
      return LatLng(_userSession.currentLat!, _userSession.currentLng!);
    }
    return null;
  }

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
        // Derecelendirme: Düşükten yükseğe
        result.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case FoodSortType.priceAsc:
        // Fiyat: Düşükten yükseğe
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case FoodSortType.distanceAsc:
        // Mesafe: Yakından uzağa
        final userLat = _userSession.currentLat;
        final userLng = _userSession.currentLng;

        if (userLat != null && userLng != null) {
          result.sort((a, b) {
            final da = _calculateDistance(
              userLat,
              userLng,
              a.latitude,
              a.longitude,
            );
            final db = _calculateDistance(
              userLat,
              userLng,
              b.latitude,
              b.longitude,
            );
            return da.compareTo(db);
          });
        } else {
          // Konum yoksa fallback: location string'inden parse et
          result.sort((a, b) {
            final da = _parseDistanceMeters(a.location);
            final db = _parseDistanceMeters(b.location);
            return da.compareTo(db);
          });
        }
        break;
      case FoodSortType.none:
        break;
    }

    _filteredListings = result;
    notifyListeners();
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double? lat2,
    double? lon2,
  ) {
    if (lat2 == null || lon2 == null) return 999999.0;
    final dLat = lat1 - lat2;
    final dLon = lon1 - lon2;
    return dLat * dLat + dLon * dLon;
  }

  /// Konum metninden mesafeyi metreye çevirir (Fallback için).
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

  String? getBottomNavRoute(int index) {
    switch (index) {
      case 0:
        return AppRoutes.foodHome;
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
