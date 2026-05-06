import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
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
    return LocaleKeys.common_selectLocation.tr();
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

      debugPrint('📊 [FoodHomeVM] Çekilen Toplam İlan: ${listings.length}');

      // Favori olanların isFavorite flag'ini güncelle
      final favoriteIds = favorites.map((f) => f.id).toSet();

      _allListings = listings.map((l) {
        final isFav = favoriteIds.contains(l.id);
        return l.copyWith(isFavorite: isFav);
      }).toList();
      
      debugPrint('✨ [FoodHomeVM] İlanlar başarıyla yüklendi ve favoriler eşleşti.');
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
            return l.category.toLowerCase() == 'yemek';
          case FoodFilter.breadPastry:
            return l.category.toLowerCase() == 'patiseri';
          case FoodFilter.market:
            return l.category.toLowerCase() == 'market';
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
    final list = List<FoodListing>.from(filteredListings);
    
    switch (section) {
      case FoodSection.nearYou:
        // Kullanıcı konumuna göre sırala (En yakın en üstte)
        final userLat = _userSession.currentLat;
        final userLng = _userSession.currentLng;
        
        if (userLat != null && userLng != null) {
          list.sort((a, b) {
            final distA = _calculateDistance(userLat, userLng, a.latitude, a.longitude);
            final distB = _calculateDistance(userLat, userLng, b.latitude, b.longitude);
            return distA.compareTo(distB);
          });
        }
        return list;

      case FoodSection.buyNow:
        // Süresi az kalanları göster (Şimdi Al)
        // Bitiş saatine göre sırala (En yakın biten en üstte)
        final now = DateTime.now();
        final buyNowList = list.where((l) {
          if (l.deliveryEndTime == null) return false;
          // Sadece henüz bitmemiş olanları al
          return l.deliveryEndTime!.isAfter(now);
        }).toList();
        
        buyNowList.sort((a, b) => a.deliveryEndTime!.compareTo(b.deliveryEndTime!));
        return buyNowList;

      case FoodSection.todayPopular:
        // Şimdilik hepsi (Gelecekte popülerlik puanına göre sıralanacak)
        return list.reversed.toList();
    }
  }

  double _calculateDistance(double lat1, double lon1, double? lat2, double? lon2) {
    if (lat2 == null || lon2 == null) return 999999.0; // Konum yoksa en sona at
    // Basit bir mesafe yaklaşımı (daha doğru sonuç için haversine kullanılabilir)
    final dLat = lat1 - lat2;
    final dLon = lon1 - lon2;
    return dLat * dLat + dLon * dLon;
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
