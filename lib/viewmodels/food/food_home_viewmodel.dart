import 'package:flutter/scheduler.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../models/food/food_filter.dart';
import '../../models/food/food_listing.dart';
import '../../models/food/order_model.dart';
import '../../services/auth/user_session.dart';
import '../../services/food/i_food_service.dart';
import '../../services/review/i_review_service.dart';
import '../../utils/routes/app_routes.dart';

/// FoodHome ekranının ViewModel'i.
class FoodHomeViewModel extends ChangeNotifier {
  FoodHomeViewModel({
    required IFoodService service,
    required IReviewService reviewService,
    required UserSession userSession,
  }) : _service = service,
       _reviewService = reviewService,
       _userSession = userSession {
    _userSession.addListener(_onUserSessionChanged);
  }

  final IFoodService _service;
  final IReviewService _reviewService;
  final UserSession _userSession;
  bool _isDisposed = false;
  bool _isInitializing = false;

  void _safeNotify() {
    if (_isDisposed) return;
    final binding = WidgetsBinding.instance;
    if (binding.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      binding.addPostFrameCallback((_) {
        if (!_isDisposed) notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  // ─── State ────────────────────────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _locationName = '';
  String get locationName => _locationName;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  bool get isSearching => _searchQuery.trim().isNotEmpty;

  FoodFilter _selectedFilter = FoodFilter.all;
  FoodFilter get selectedFilter => _selectedFilter;

  List<FoodListing> _allListings = [];
  List<FoodListing> _popularListings = [];
  List<FoodListing> _popularTodayListings = [];
  List<OrderModel> _activeOrders = [];
  List<OrderModel> get activeOrders => List.unmodifiable(_activeOrders);
  OrderModel? _pendingReviewOrder;
  OrderModel? get pendingReviewOrder => _pendingReviewOrder;
  final Set<int> _submittedReviewOrderIds = {};

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  String get appBarTitle {
    final addr = _userSession.currentAddress;
    if (addr != null && addr.isNotEmpty) return addr;
    return LocaleKeys.common_selectLocation.tr();
  }

  Color get appBarColor => const Color(0xFFFE8800);

  double? get userLat => _userSession.currentLat;
  double? get userLng => _userSession.currentLng;

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
    if (_isInitializing) return;
    _isInitializing = true;
    debugPrint('🚀 [FoodHomeVM] Başlatılıyor...');
    _isLoading = true;
    _safeNotify();

    try {
      final results = await Future.wait([
        _service.getUserLocationName(),
        _service.getFeaturedListings(),
        _service.getFavorites(), // Favorileri de çek
        _service.getPopularListings(), // Popülerleri de çek
        _service
            .getPopularTodayListings(), // Bugünün Popülerlerini (tükendiler dahil) çek
        _fetchLatestActiveOrder(),
      ]);

      _locationName = results[0] as String;
      final listings = results[1] as List<FoodListing>;
      final favorites = results[2] as List<FoodListing>;
      final populars = results[3] as List<FoodListing>;
      final popularTodays = results[4] as List<FoodListing>;

      debugPrint('📊 [FoodHomeVM] Çekilen Toplam İlan: ${listings.length}');
      debugPrint('📊 [FoodHomeVM] Çekilen Popüler İlan: ${populars.length}');
      debugPrint(
        '📊 [FoodHomeVM] Çekilen Popüler Bugün İlan: ${popularTodays.length}',
      );

      // Favori olanların isFavorite flag'ini güncelle
      final favoriteIds = favorites.map((f) => f.id).toSet();

      _allListings = listings.map((l) {
        final isFav = favoriteIds.contains(l.id);
        return l.copyWith(isFavorite: isFav);
      }).toList();

      _popularListings = populars.map((l) {
        final isFav = favoriteIds.contains(l.id);
        return l.copyWith(isFavorite: isFav);
      }).toList();

      _popularTodayListings = popularTodays.map((l) {
        final isFav = favoriteIds.contains(l.id);
        return l.copyWith(isFavorite: isFav);
      }).toList();

      debugPrint(
        '✨ [FoodHomeVM] İlanlar başarıyla yüklendi ve favoriler eşleşti.',
      );
    } catch (e) {
      debugPrint('❌ [FoodHomeVM] Hata: $e');
    } finally {
      _isInitializing = false;
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<void> _fetchLatestActiveOrder() async {
    try {
      final results = await Future.wait([
        _service.getMyOrders(),
        _reviewService.getMyReviews(),
      ]);
      final orders = results[0] as List<OrderModel>;
      final reviewedOrderIds = (results[1] as List)
          .map((review) => review.orderId)
          .whereType<int>()
          .toSet();

      final pendingReviews = orders.where((order) {
        final status = order.orderStatus.toLowerCase().replaceAll('-', '_');
        return status == 'picked_up' &&
            !order.hasReview &&
            !reviewedOrderIds.contains(order.id) &&
            !_submittedReviewOrderIds.contains(order.id);
      }).toList()..sort((a, b) => a.orderTime.compareTo(b.orderTime));

      _pendingReviewOrder = pendingReviews.isEmpty ? null : pendingReviews.first;

      final activeOrders = orders.where((order) {
        final status = order.orderStatus.toLowerCase().replaceAll('-', '_');
        return status != 'cancelled' &&
            status != 'canceled' &&
            status != 'picked_up' &&
            status != 'completed';
      }).toList()..sort((a, b) => b.orderTime.compareTo(a.orderTime));

      _activeOrders = activeOrders;
    } catch (e) {
      _activeOrders = [];
      _pendingReviewOrder = null;
      debugPrint('❌ [FoodHomeVM] Aktif sipariş hatası: $e');
    }
  }

  Future<void> refreshOrders() async {
    await _fetchLatestActiveOrder();
    _safeNotify();
  }

  Future<void> onReviewSubmitted(int orderId) async {
    _submittedReviewOrderIds.add(orderId);
    if (_pendingReviewOrder?.id == orderId) {
      _pendingReviewOrder = null;
      _safeNotify();
    }
    await refreshOrders();
  }

  Future<bool> cancelOrder(OrderModel order) async {
    final success = await _service.cancelOrder(order.id);
    if (success) {
      _activeOrders = _activeOrders
          .where((activeOrder) => activeOrder.id != order.id)
          .toList();
      _safeNotify();
    }
    return success;
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

  List<FoodListing> get filteredPopularTodayListings {
    var list = _popularTodayListings;
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

  List<FoodListing> get filteredPopularListings {
    var list = _popularListings;
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

  List<FoodListing> get searchResults {
    if (!isSearching) return const [];

    final uniqueListings = <String, FoodListing>{};
    for (final listing in [
      ..._allListings,
      ..._popularListings,
      ..._popularTodayListings,
    ]) {
      uniqueListings[listing.id] = listing;
    }

    final query = _searchQuery.trim().toLowerCase();
    return uniqueListings.values.where((listing) {
      if (!_matchesSelectedFilter(listing)) return false;

      return listing.title.toLowerCase().contains(query) ||
          listing.shopName.toLowerCase().contains(query) ||
          listing.category.toLowerCase().contains(query) ||
          (listing.description?.toLowerCase().contains(query) ?? false) ||
          listing.location.toLowerCase().contains(query);
    }).toList();
  }

  bool _matchesSelectedFilter(FoodListing listing) {
    switch (_selectedFilter) {
      case FoodFilter.food:
        return listing.category.toLowerCase() == 'yemek';
      case FoodFilter.breadPastry:
        return listing.category.toLowerCase() == 'patiseri';
      case FoodFilter.market:
        return listing.category.toLowerCase() == 'market';
      case FoodFilter.buyNow:
        return listing.section == FoodSection.buyNow;
      case FoodFilter.all:
        return true;
    }
  }

  List<FoodListing> sectionListings(FoodSection section) {
    switch (section) {
      case FoodSection.nearYou:
        final list = List<FoodListing>.from(filteredListings);
        // Kullanıcı konumuna göre sırala (En yakın en üstte)
        final userLat = _userSession.currentLat;
        final userLng = _userSession.currentLng;

        if (userLat != null && userLng != null) {
          list.sort((a, b) {
            final distA = _calculateDistance(
              userLat,
              userLng,
              a.latitude,
              a.longitude,
            );
            final distB = _calculateDistance(
              userLat,
              userLng,
              b.latitude,
              b.longitude,
            );
            return distA.compareTo(distB);
          });
        }
        return list;

      case FoodSection.buyNow:
        final list = List<FoodListing>.from(filteredListings);
        // Süresi az kalanları göster (Şimdi Al)
        // Bitiş saatine göre sırala (En yakın biten en üstte)
        final now = DateTime.now();
        final buyNowList = list.where((l) {
          if (l.deliveryEndTime == null) return false;
          // Sadece henüz bitmemiş olanları al
          return l.deliveryEndTime!.isAfter(now);
        }).toList();

        buyNowList.sort(
          (a, b) => a.deliveryEndTime!.compareTo(b.deliveryEndTime!),
        );
        return buyNowList;

      case FoodSection.todayPopular:
        return filteredPopularListings;

      case FoodSection.todayPopularAll:
        return filteredPopularTodayListings;
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double? lat2,
    double? lon2,
  ) {
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
    }
    final popIndex = _popularListings.indexWhere((l) => l.id == id);
    if (popIndex != -1) {
      _popularListings = List.of(_popularListings)
        ..[popIndex] = _popularListings[popIndex].copyWith(
          isFavorite: !_popularListings[popIndex].isFavorite,
        );
    }
    final popTodayIndex = _popularTodayListings.indexWhere((l) => l.id == id);
    if (popTodayIndex != -1) {
      _popularTodayListings = List.of(_popularTodayListings)
        ..[popTodayIndex] = _popularTodayListings[popTodayIndex].copyWith(
          isFavorite: !_popularTodayListings[popTodayIndex].isFavorite,
        );
    }
    _safeNotify();

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
      }
      if (popIndex != -1) {
        _popularListings = List.of(_popularListings)
          ..[popIndex] = _popularListings[popIndex].copyWith(
            isFavorite: !_popularListings[popIndex].isFavorite,
          );
      }
      if (popTodayIndex != -1) {
        _popularTodayListings = List.of(_popularTodayListings)
          ..[popTodayIndex] = _popularTodayListings[popTodayIndex].copyWith(
            isFavorite: !_popularTodayListings[popTodayIndex].isFavorite,
          );
      }
      _safeNotify();
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

      final newPopListings = _popularListings.map((l) {
        final isFav = favoriteIds.contains(l.id);
        if (l.isFavorite != isFav) {
          changed = true;
          return l.copyWith(isFavorite: isFav);
        }
        return l;
      }).toList();

      final newPopTodayListings = _popularTodayListings.map((l) {
        final isFav = favoriteIds.contains(l.id);
        if (l.isFavorite != isFav) {
          changed = true;
          return l.copyWith(isFavorite: isFav);
        }
        return l;
      }).toList();

      if (changed) {
        _allListings = newListings;
        _popularListings = newPopListings;
        _popularTodayListings = newPopTodayListings;
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
