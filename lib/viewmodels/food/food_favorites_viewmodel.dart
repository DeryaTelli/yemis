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
  FoodFavoritesViewModel(this._service);

  final IFoodService _service;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  // ─── Nav ──────────────────────────────────────────────
  int _selectedIndex = 3;
  int get selectedIndex => _selectedIndex;

  // ─── Favorites ────────────────────────────────────────
  List<FoodListing> _favorites = [];
  List<FoodListing> get favorites => _favorites;

  // ─── Init ─────────────────────────────────────────────

  Future<void> _loadFavorites() async {
    if (_isLoading) return;
    _isLoading = true;
    _safeNotify();

    try {
      _favorites = await _service.getFavorites();
    } catch (e) {
      debugPrint('❌ [FoodFavoritesVM] Yükleme hatası: $e');
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  /// Favoriler ekranına her dönüldüğünde çağrılır.
  void refresh() {
    _loadFavorites();
  }

  // ─── Actions ──────────────────────────────────────────

  Future<void> toggleFavorite(String id) async {
    // Optimistic UI: Önce kalbin içini boşalt (kullanıcıya geri bildirim ver)
    final index = _favorites.indexWhere((f) => f.id == id);
    if (index != -1) {
      _favorites = List.of(_favorites)
        ..[index] = _favorites[index].copyWith(isFavorite: false);
      _safeNotify();
    }

    // Kısa bir süre bekle ki kullanıcı kalbin boşaldığını görsün (isteğe bağlı ama istenmişti)
    await Future.delayed(const Duration(milliseconds: 300));

    // Listeden çıkar
    final removedItem = _favorites.firstWhere((f) => f.id == id);
    _favorites = _favorites.where((f) => f.id != id).toList();
    _safeNotify();

    try {
      await _service.toggleFavorite(id);
    } catch (e) {
      // Hata olursa geri ekle ve favori durumunu geri al
      _favorites = [..._favorites, removedItem.copyWith(isFavorite: true)];
      _safeNotify();
      debugPrint('❌ [FoodFavoritesVM] Favori toggle hatası: $e');
    }
  }

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    _safeNotify();
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
