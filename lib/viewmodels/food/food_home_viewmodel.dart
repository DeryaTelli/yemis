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
    // UserSession dinle -> konum değişince başlığı güncelle
    _userSession.addListener(_onUserSessionChanged);
  }

  final IFoodService _service;
  final UserSession _userSession;

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
      notifyListeners();
    }
  }

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
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

  void toggleFavorite(String id) {
    _service.toggleFavorite(id);
    final index = _allListings.indexWhere((l) => l.id == id);
    if (index != -1) {
      _allListings = List.of(_allListings)
        ..[index] = _allListings[index].copyWith(
          isFavorite: !_allListings[index].isFavorite,
        );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _userSession.removeListener(_onUserSessionChanged);
    super.dispose();
  }
}
