import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../models/food/food_listing.dart';
import '../../models/food/food_review.dart';
import '../../services/food/i_food_service.dart';
import '../../services/location/location_service.dart';

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
        _listingId = listingId,
        _locationService = LocationService();

  final IFoodService _service;
  final String _listingId;
  final LocationService _locationService;

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

  Position? _userPosition;
  Position? get userPosition => _userPosition;

  double? _distanceInMeters;

  String get distanceText {
    if (_distanceInMeters == null) return "Hesaplanıyor...";
    if (_distanceInMeters! < 1000) {
      return "${_distanceInMeters!.toStringAsFixed(0)} m";
    } else {
      return "${(_distanceInMeters! / 1000).toStringAsFixed(1)} km";
    }
  }

  String get deliveryText {
    if (_listing == null || _listing!.deliveryStartTime == null) return _listing?.timeRange ?? "";
    
    final now = DateTime.now();
    final start = _listing!.deliveryStartTime!;
    
    final isToday = now.year == start.year && now.month == start.month && now.day == start.day;
    
    if (isToday) {
      return "Bugün Al | ${_listing!.timeRange}";
    } else {
      final formatter = _TurkishDateFormatter();
      return "${formatter.format(start)} | ${_listing!.timeRange}";
    }
  }

  LatLng? get userLatLng => _userPosition != null 
      ? LatLng(_userPosition!.latitude, _userPosition!.longitude) 
      : null;

  LatLng? get businessLatLng => _listing?.latitude != null && _listing?.longitude != null
      ? LatLng(_listing!.latitude!, _listing!.longitude!)
      : null;

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

    await _fetchUserLocation();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchUserLocation() async {
    try {
      final hasPermission = await _locationService.checkAndRequestPermission();
      if (hasPermission) {
        _userPosition = await _locationService.getCurrentPosition();
        _calculateDistance();
      }
    } catch (e) {
      debugPrint("Error fetching location in ViewModel: $e");
    }
  }

  void _calculateDistance() {
    if (_userPosition != null && _listing?.latitude != null && _listing?.longitude != null) {
      _distanceInMeters = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        _listing!.latitude!,
        _listing!.longitude!,
      );
    }
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

class _TurkishDateFormatter {
  String format(DateTime date) {
    const months = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return "${date.day} ${months[date.month]}";
  }
}
