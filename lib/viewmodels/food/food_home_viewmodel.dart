import 'package:flutter/material.dart';
import '../../models/food/food_filter.dart';
import '../../models/food/food_listing.dart';
import '../../services/food/i_food_service.dart';

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

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
    debugPrint("Food Tab Selected: $index");
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
    final index = _allListings.indexWhere((l) => l.id == id);
    if (index == -1) return;
    final updated = _allListings[index].copyWith(
      isFavorite: !_allListings[index].isFavorite,
    );
    _allListings = List.of(_allListings)..[index] = updated;
    notifyListeners();
  }
}
