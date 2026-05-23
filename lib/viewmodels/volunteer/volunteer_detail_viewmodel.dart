import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../models/volunteer/shelter_model.dart';
import '../../services/location/location_service.dart';
import '../../services/volunteer/i_volunteer_service.dart';

import '../../services/auth/user_session.dart';

class VolunteerDetailViewModel extends ChangeNotifier {
  VolunteerDetailViewModel({
    required IVolunteerService service,
    required String listingId,
    required UserSession userSession,
    VolunteerListing? initialListing,
  })  : _service = service,
        _listingId = listingId,
        _userSession = userSession,
        _locationService = LocationService(),
        _listing = initialListing;

  final IVolunteerService _service;
  final String _listingId;
  final UserSession _userSession;
  final LocationService _locationService;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  // ─── State ──────────────────────────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  VolunteerListing? _listing;
  VolunteerListing? get listing => _listing;

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

  LatLng? get userLatLng => _userPosition != null
      ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
      : null;

  LatLng? get listingLatLng => _listing?.latitude != null && _listing?.longitude != null
      ? LatLng(_listing!.latitude!, _listing!.longitude!)
      : null;

  ShelterModel? _nearestShelter;
  ShelterModel? get nearestShelter => _nearestShelter;

  bool _isShelterLoading = false;
  bool get isShelterLoading => _isShelterLoading;

  LatLng? get shelterLatLng {
    if (_nearestShelter != null) {
      return LatLng(_nearestShelter!.latitude, _nearestShelter!.longitude);
    }
    return null;
  }

  String get shelterName => _nearestShelter?.name ?? 'Yakında barınak bulunamadı';

  String get shelterAddress => _nearestShelter?.address ?? '';

  String get distanceToShelterText {
    if (_nearestShelter == null) return "";
    return "${_nearestShelter!.distanceKm.toStringAsFixed(1)} km";
  }

  // ─── Init ────────────────────────────────────────────────

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final freshListing = await _service.getVolunteerDetail(_listingId);
      _listing = freshListing.copyWith(
        taskId: freshListing.taskId ?? _listing?.taskId,
        deliveryStatus: freshListing.deliveryStatus == DeliveryStatus.pendingOwnerApproval
            ? freshListing.deliveryStatus
            : (_listing?.deliveryStatus ?? freshListing.deliveryStatus),
        acceptedByUserId: freshListing.acceptedByUserId ?? _listing?.acceptedByUserId,
      );

      await _fetchUserLocation();

      // İlan verisi geldiyse ilanın konumuna göre yakındaki barınakları çek
      if (_listing != null &&
          _listing!.latitude != null &&
          _listing!.longitude != null) {
        await fetchNearbyShelters();
      }
    } catch (e) {
      debugPrint("Error initializing volunteer detail: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNearbyShelters() async {
    if (_listing == null || _listing!.latitude == null || _listing!.longitude == null) return;

    _isShelterLoading = true;
    notifyListeners();

    try {
      final shelters = await _service.getNearbyShelters(
        lat: _listing!.latitude!,
        lng: _listing!.longitude!,
        radiusKm: 50,
      );

      if (shelters.isNotEmpty) {
        // En yakını göster (API zaten mesafeye göre sıralı döndürüyor olmalı)
        _nearestShelter = shelters.first;
      } else {
        _nearestShelter = null;
      }
    } catch (e) {
      debugPrint("Error fetching nearby shelters: $e");
      _nearestShelter = null;
    } finally {
      _isShelterLoading = false;
      notifyListeners();
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

  // ─── Gönüllü Ol ─────────────────────────────────────────

  bool _isVolunteering = false;
  bool get isVolunteering => _isVolunteering;

  String? _volunteerError;
  String? get volunteerError => _volunteerError;

  /// Kullanıcının bu ilana bekleyen başvurusu var mı?
  /// taskId varsa ve durum pendingOwnerApproval ise iptal butonu gösterilir.
  /// acceptedByUserId her zaman API'den gelmeyebileceğinden taskId varlığı yeterli kontrol.
  bool get isMyApplicationPending {
    final item = _listing;
    if (item == null) return false;
    if (item.deliveryStatus != DeliveryStatus.pendingOwnerApproval) return false;
    // taskId varsa bu kullanıcının başvurusu demektir
    if (item.taskId != null && item.taskId!.isNotEmpty) return true;
    // taskId yoksa acceptedByUserId ile dene
    final currentId = int.tryParse(_userSession.currentUser?.id ?? '');
    if (currentId == null || item.acceptedByUserId == null) return false;
    return item.acceptedByUserId == currentId;
  }

  Future<bool> becomeVolunteer() async {
    if (_listing == null) return false;

    final mealId = int.tryParse(_listing!.id);
    if (mealId == null) {
      _volunteerError = 'Geçersiz ilan ID.';
      notifyListeners();
      return false;
    }

    _isVolunteering = true;
    _volunteerError = null;
    notifyListeners();

    try {
      final success = await _service.becomeVolunteer(mealId);
      if (!success) {
        _volunteerError = 'Gönüllü ataması başarısız oldu. Lütfen tekrar deneyin.';
      }
      return success;
    } catch (e) {
      _volunteerError = 'Bir hata oluştu: $e';
      debugPrint('Error in becomeVolunteer: $e');
      return false;
    } finally {
      _isVolunteering = false;
      notifyListeners();
    }
  }

  // ─── Başvuru İptal ──────────────────────────────────────

  bool _isCancelling = false;
  bool get isCancelling => _isCancelling;

  String? _cancelError;
  String? get cancelError => _cancelError;

  Future<bool> cancelVolunteer() async {
    final taskIdStr = _listing?.taskId ?? _listing?.id;
    if (taskIdStr == null) {
      _cancelError = 'Görev ID bulunamadı.';
      notifyListeners();
      return false;
    }

    final taskId = int.tryParse(taskIdStr);
    if (taskId == null) {
      _cancelError = 'Geçersiz görev ID.';
      notifyListeners();
      return false;
    }

    _isCancelling = true;
    _cancelError = null;
    notifyListeners();

    try {
      final success = await _service.cancelTask(taskId);
      if (!success) {
        _cancelError = 'İptal işlemi başarısız oldu. Lütfen tekrar deneyin.';
      }
      return success;
    } catch (e) {
      _cancelError = 'Bir hata oluştu: $e';
      debugPrint('Error in cancelVolunteer: $e');
      return false;
    } finally {
      _isCancelling = false;
      notifyListeners();
    }
  }
}
