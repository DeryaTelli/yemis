import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../services/location/location_service.dart';
import '../../services/volunteer/i_volunteer_service.dart';

class VolunteerDetailViewModel extends ChangeNotifier {
  VolunteerDetailViewModel({
    required IVolunteerService service,
    required String listingId,
  })  : _service = service,
        _listingId = listingId,
        _locationService = LocationService();

  final IVolunteerService _service;
  final String _listingId;
  final LocationService _locationService;

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

  LatLng? get shelterLatLng => _listing?.shelterLatitude != null && _listing?.shelterLongitude != null
      ? LatLng(_listing!.shelterLatitude!, _listing!.shelterLongitude!)
      : null;

  String get shelterName => _listing?.shelterName ?? 'En Yakın Barınak';

  String get shelterAddress => _listing?.shelterAddress ?? 'Barınak Lokasyonu';

  // ─── Init ────────────────────────────────────────────────

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _listing = await _service.getVolunteerDetail(_listingId);

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

  // ─── Gönüllü Ol ─────────────────────────────────────────

  Future<void> volunteer() async {
    // API Call
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
