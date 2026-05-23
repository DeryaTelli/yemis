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
    FoodListing? initialListing,
  }) : _service = service,
       _listingId = listingId,
       _listing = initialListing,
       _locationService = LocationService();

  final IFoodService _service;
  final String _listingId;
  final LocationService _locationService;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

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
    if (_listing == null || _listing!.deliveryStartTime == null)
      return _listing?.timeRange ?? "";

    final now = DateTime.now();
    final start = _listing!.deliveryStartTime!;

    final isToday =
        now.year == start.year &&
        now.month == start.month &&
        now.day == start.day;

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

  LatLng? get businessLatLng =>
      _listing?.latitude != null && _listing?.latitude != 0 &&
      _listing?.longitude != null && _listing?.longitude != 0
      ? LatLng(_listing!.latitude!, _listing!.longitude!)
      : null;

  // ─── Init ────────────────────────────────────────────────

  Future<void> init() async {
    _isLoading = true;
    _safeNotify();

    try {
      final results = await Future.wait([
        _service.getFoodDetail(_listingId),
        _service.getFoodReviews(_listingId),
      ]);

      final fetchedListing = results[0] as FoodListing;
      _reviews = results[1] as List<FoodReview>;

      // API'den gelen veride koordinatlar eksikse, başlangıçtaki koordinatları koru
      if (fetchedListing.latitude == null || fetchedListing.longitude == null) {
        _listing = fetchedListing.copyWith(
          latitude: _listing?.latitude,
          longitude: _listing?.longitude,
        );
      } else {
        _listing = fetchedListing;
      }

      await _fetchUserLocation();
    } catch (e) {
      debugPrint('Error initializing food detail: $e');
    } finally {
      _isLoading = false;
      _safeNotify();
    }
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
    if (_userPosition != null &&
        _listing?.latitude != null &&
        _listing?.longitude != null) {
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
    _safeNotify();
  }

  // ─── Genişletme ──────────────────────────────────────────

  void toggleDetailExpanded() {
    _isDetailExpanded = !_isDetailExpanded;
    _safeNotify();
  }

  // ─── Favori ──────────────────────────────────────────────

  Future<void> toggleFavorite() async {
    if (_listing == null) return;
    
    // UI'da hemen tepki ver (Optimistic UI)
    final oldState = _listing!.isFavorite;
    _listing = _listing!.copyWith(isFavorite: !oldState);
    _safeNotify();

    // API'ye gönder
    try {
      await _service.toggleFavorite(_listingId);
    } catch (e) {
      // Hata olursa geri al
      _listing = _listing!.copyWith(isFavorite: oldState);
      _safeNotify();
      debugPrint('❌ [FoodDetailVM] Favori toggle hatası: $e');
    }
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
      '',
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return "${date.day} ${months[date.month]}";
  }
}
