import 'package:flutter/material.dart';
import '../../models/food/food_listing.dart';
import '../../models/food/food_review.dart';
import '../../services/food/i_food_service.dart';

/// Food Detay ekranının ViewModel'i.
///
/// Sorumluluklar:
/// - İlan detayını ve yorumları yükler
/// - Aktif sekmeyi (Sipariş / Yorum) yönetir
/// - "Daha Fazla Detay" bölümünün açık/kapalı durumunu tutar
/// - Favori toggle & Rezerve Et aksiyon noktaları
class FoodDetailViewModel extends ChangeNotifier {
  FoodDetailViewModel({
    required IFoodService service,
    required String listingId,
  })  : _service = service,
        _listingId = listingId;

  final IFoodService _service;
  final String _listingId;

  // ─── State ──────────────────────────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FoodListing? _listing;
  FoodListing? get listing => _listing;

  List<FoodReview> _reviews = [];
  List<FoodReview> get reviews => _reviews;

  /// 0 = Sipariş, 1 = Yorum
  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  bool _isDetailExpanded = false;
  bool get isDetailExpanded => _isDetailExpanded;

  // ─── Init ────────────────────────────────────────────────

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _service.getFoodDetail(_listingId),
      _service.getFoodReviews(_listingId),
    ]);

    _listing = results[0] as FoodListing;
    _reviews = results[1] as List<FoodReview>;

    _isLoading = false;
    notifyListeners();
  }

  // ─── Tab ────────────────────────────────────────────────

  void onTabChanged(int index) {
    if (_selectedTab == index) return;
    _selectedTab = index;
    notifyListeners();
  }

  // ─── Genişletme ──────────────────────────────────────────

  void toggleDetailExpanded() {
    _isDetailExpanded = !_isDetailExpanded;
    notifyListeners();
  }

  // ─── Favori ──────────────────────────────────────────────

  void toggleFavorite() {
    if (_listing == null) return;
    _listing = _listing!.copyWith(isFavorite: !_listing!.isFavorite);
    notifyListeners();
  }

  // ─── Rezervasyon ─────────────────────────────────────────

  /// Gerçek backend entegrasyonunda burada API çağrısı yapılır.
  Future<void> reserve() async {
    // TODO: ApiService.createReservation(_listingId)
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
