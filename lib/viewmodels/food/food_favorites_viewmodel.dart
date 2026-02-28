import 'package:flutter/material.dart';
import '../../models/food/food_listing.dart';
import '../../services/food/i_food_service.dart';
import '../../services/food/mock_food_service.dart';
import '../../utils/routes/app_routes.dart';

/// Favoriler sayfasının ViewModel'i.
///
/// [MockFoodService] singleton üzerinden favori ilanları okur
/// ve favori durumu değiştiğinde UI'yi günceller.
class FoodFavoritesViewModel extends ChangeNotifier {
  FoodFavoritesViewModel() : _service = MockFoodService() {
    _loadFavorites();
  }

  final IFoodService _service;

  // ─── Nav ──────────────────────────────────────────────
  int _selectedIndex = 3;
  int get selectedIndex => _selectedIndex;

  // ─── Favorites ────────────────────────────────────────
  List<FoodListing> _favorites = [];
  List<FoodListing> get favorites => _favorites;

  // ─── Init ─────────────────────────────────────────────

  void _loadFavorites() {
    _favorites = _service.getFavorites();
    notifyListeners();
  }

  /// Favoriler ekranına her dönüldüğünde çağrılır.
  void refresh() {
    _loadFavorites();
  }

  // ─── Actions ──────────────────────────────────────────

  void toggleFavorite(String id) {
    _service.toggleFavorite(id);
    _favorites = _service.getFavorites();
    notifyListeners();
  }

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
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
