import 'package:flutter/material.dart';
import '../../models/food/food_filter.dart';
import '../../models/food/food_listing.dart';
import '../../services/food/i_food_service.dart';
import '../../utils/routes/app_routes.dart';

/// FoodHome ekranının ViewModel'i.
///
/// Sorumluluklar:
/// - Konum adını yükler
/// - Arama sorgusunu yönetir
/// - Filtre chip seçimini yönetir
/// - İlanları filtreli olarak sunar
class FoodHomeViewModel extends ChangeNotifier {
  FoodHomeViewModel({required IFoodService service}) : _service = service;

  final IFoodService _service;

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

  String get appBarTitle => _locationName.isEmpty ? 'Konum yükleniyor…' : _locationName;
  Color get appBarColor => const Color(0xFFFE8800);

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
    debugPrint("Food Tab Selected: $index");
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

  // ─── Init ─────────────────────────────────────────────

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _service.getUserLocationName(),
      _service.getFeaturedListings(),
    ]);

    _locationName = results[0] as String;
    _allListings = results[1] as List<FoodListing>;

    _isLoading = false;
    notifyListeners();
  }

  // ─── Arama ────────────────────────────────────────────

  void onSearchChanged(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ─── Filtre ───────────────────────────────────────────

  void onFilterChanged(FoodFilter filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    notifyListeners();
  }

  // ─── Filtrelenmiş İlanlar ─────────────────────────────

  List<FoodListing> get filteredListings {
    var list = _allListings;

    // Kategori filtresi
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

    // Metin filtresi
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

  /// Section'a göre filtrelenmiş ilanlar.
  List<FoodListing> sectionListings(FoodSection section) {
    return filteredListings.where((l) => l.section == section).toList();
  }

  // ─── Favori Toggle ───────────────────────────────────

  void toggleFavorite(String id) {
    // Singleton servisteki mutable listeyi güncelle
    _service.toggleFavorite(id);
    // Yerel kopyayı da senkron olarak güncelle
    final index = _allListings.indexWhere((l) => l.id == id);
    if (index != -1) {
      _allListings = List.of(_allListings)
        ..[index] = _allListings[index].copyWith(
          isFavorite: !_allListings[index].isFavorite,
        );
    }
    notifyListeners();
  }
}
