import 'package:flutter/material.dart';
import '../../models/food/food_filter.dart';
import '../../models/food/food_listing.dart';
import '../../services/auth/user_session.dart';
import '../../services/food/i_food_service.dart';
import '../../utils/routes/app_routes.dart';

/// FoodHome ekranının ViewModel'i.
class FoodHomeViewModel extends ChangeNotifier {
  FoodHomeViewModel({
    required IFoodService service,
    required UserSession userSession,
  }) : _service = service,
       _userSession = userSession {
    _userSession.addListener(_onUserSessionChanged);
  }

  final IFoodService _service;
  final UserSession _userSession;
  bool _isDisposed = false;

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  // ─── State ────────────────────────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _locationName = '';
  String get locationName => _locationName;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  FoodFilter _selectedFilter = FoodFilter.all;
  FoodFilter get selectedFilter => _selectedFilter;

  List<FoodListing> _allListings = [];

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  String get appBarTitle {
    final addr = _userSession.currentAddress;
    if (addr != null && addr.isNotEmpty) return addr;
    return 'Konum Seçiniz';
  }

  Color get appBarColor => const Color(0xFFFE8800);

  void _onUserSessionChanged() {
    if (_userSession.currentAddress != null) {
      _locationName = _userSession.currentAddress!;
      _safeNotify();
    }
  }

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    _safeNotify();
  }

  String? getBottomNavRoute(int index) {
    switch (index) {
      case 0:
        return AppRoutes.foodHome;
      case 2:
        return AppRoutes.home;
      case 1:
        return AppRoutes.foodSearch;
      case 3:
        return AppRoutes.foodFavorites;
      case 4:
        return AppRoutes.foodProfile;
      default:
        return null;
    }
  }

  // ─── Init ─────────────────────────────────────────────

  Future<void> init() async {
    debugPrint('🚀 [FoodHomeVM] Başlatılıyor...');
    _isLoading = true;
    _safeNotify();

    try {
      final results = await Future.wait([
        _service.getUserLocationName(),
        _service.getFeaturedListings(),
        _service.getFavorites(), // Favorileri de çek
      ]);

      _locationName = results[0] as String;
      final listings = results[1] as List<FoodListing>;
      final favorites = results[2] as List<FoodListing>;

      // Favori olanların isFavorite flag'ini güncelle
      final favoriteIds = favorites.map((f) => f.id).toSet();

      _allListings = listings.map((l) {
        final isFav = favoriteIds.contains(l.id);
        return l.copyWith(isFavorite: isFav);
      }).toList();
    } catch (e) {
      debugPrint('❌ [FoodHomeVM] Hata: $e');
    }

    _isLoading = false;
    _safeNotify();
  }

  // ─── Arama ────────────────────────────────────────────

  void onSearchChanged(String query) {
    _searchQuery = query;
    _safeNotify();
  }

  // ─── Filtre ───────────────────────────────────────────

  void onFilterChanged(FoodFilter filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    _safeNotify();
  }

  // ─── Filtrelenmiş İlanlar ─────────────────────────────

  List<FoodListing> get filteredListings {
    var list = _allListings;
    if (_selectedFilter != FoodFilter.all) {
      list = list.where((l) {
        switch (_selectedFilter) {
          case FoodFilter.food:
            return l.category == 'Yemek';
          case FoodFilter.breadPastry:
            return l.category == 'Ekmek & Pasta' || l.category == 'Pasta';
          case FoodFilter.market:
            return l.category == 'Market';
          case FoodFilter.buyNow:
            return l.section == FoodSection.buyNow;
          case FoodFilter.all:
            return true;
        }
      }).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((l) {
        return l.title.toLowerCase().contains(q) ||
            l.shopName.toLowerCase().contains(q) ||
            l.category.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  List<FoodListing> sectionListings(FoodSection section) {
    return filteredListings.where((l) => l.section == section).toList();
  }

  // ─── Favori Toggle ───────────────────────────────────

  Future<void> toggleFavorite(String id) async {
    // UI'da hemen tepki ver (Optimistic UI)
    final index = _allListings.indexWhere((l) => l.id == id);
    if (index != -1) {
      _allListings = List.of(_allListings)
        ..[index] = _allListings[index].copyWith(
          isFavorite: !_allListings[index].isFavorite,
        );
      _safeNotify();
    }

    // API'ye gönder
    try {
      await _service.toggleFavorite(id);
    } catch (e) {
      // Hata olursa geri al (Rollback)
      if (index != -1) {
        _allListings = List.of(_allListings)
          ..[index] = _allListings[index].copyWith(
            isFavorite: !_allListings[index].isFavorite,
          );
        _safeNotify();
      }
      debugPrint('❌ [FoodHomeVM] Favori toggle hatası: $e');
    }
  }

  /// Sadece favori durumlarını günceller (Sayfa geri gelindiğinde vs.)
  Future<void> refreshFavorites() async {
    try {
      final favorites = await _service.getFavorites();
      final favoriteIds = favorites.map((f) => f.id).toSet();

      bool changed = false;
      final newListings = _allListings.map((l) {
        final isFav = favoriteIds.contains(l.id);
        if (l.isFavorite != isFav) {
          changed = true;
          return l.copyWith(isFavorite: isFav);
        }
        return l;
      }).toList();

      if (changed) {
        _allListings = newListings;
        _safeNotify();
      }
    } catch (e) {
      debugPrint('❌ [FoodHomeVM] Favori yenileme hatası: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _userSession.removeListener(_onUserSessionChanged);
    super.dispose();
  }
}
