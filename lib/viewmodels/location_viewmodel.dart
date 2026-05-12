import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/auth/address_model.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/auth/user_session.dart';
import '../../utils/locale_keys.dart';

enum LocationPermissionState { unknown, granted, denied }

enum _PendingAction { none, share, pick }

class _GeoResult {
  final String addressLine;
  final String city;
  final String district;
  final String neighborhood;

  const _GeoResult({
    required this.addressLine,
    required this.city,
    required this.district,
    required this.neighborhood,
  });
}

class LocationViewModel extends ChangeNotifier {
  LocationViewModel({
    required UserSession userSession,
    required IAuthService authService,
  }) : _userSession = userSession,
       _authService = authService;

  final UserSession _userSession;
  final IAuthService _authService;

  static const String _prefKey = 'location_onboarding_done';
  static const String _prefAddressKey = 'current_location_address';
  static const String _prefLatKey = 'current_lat';
  static const String _prefLngKey = 'current_lng';

  // ─── State ───────────────────────────────────────

  LocationPermissionState _permissionState = LocationPermissionState.unknown;
  LocationPermissionState get permissionState => _permissionState;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorKey;
  String? get errorKey => _errorKey;

  bool get hasPermission => _permissionState == LocationPermissionState.granted;

  _PendingAction _pendingAction = _PendingAction.none;

  // ─── Init ─────────────────────────────────────────

  Future<void> init() async {
    final status = await Permission.locationWhenInUse.status;
    _permissionState = status.isGranted
        ? LocationPermissionState.granted
        : LocationPermissionState.denied;

    // 1. Önce SharedPreferences'dan oku
    final prefs = await SharedPreferences.getInstance();
    String? savedAddress = prefs.getString(_prefAddressKey);
    double? savedLat = prefs.getDouble(_prefLatKey);
    double? savedLng = prefs.getDouble(_prefLngKey);

    // 2. Eğer yerelde yoksa API'den çekmeye çalış
    if (savedAddress == null) {
      try {
        final addresses = await _authService.getAddresses();
        if (addresses.isNotEmpty) {
          final def = addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => addresses.first,
          );
          savedAddress = def.addressLine;
          savedLat = def.latitude;
          savedLng = def.longitude;

          // Yerel belleğe de yaz
          await prefs.setString(_prefAddressKey, savedAddress);
          await prefs.setDouble(_prefLatKey, savedLat);
          await prefs.setDouble(_prefLngKey, savedLng);
          await prefs.setBool(_prefKey, true);
        }
      } catch (_) {}
    }

    if (savedAddress != null) {
      _userSession.updateLocation(savedAddress, lat: savedLat, lng: savedLng);
    }

    notifyListeners();
  }

  // ─── İzin: durum yenile ──────────────────────────

  Future<bool> _checkCurrentPermission() async {
    final status = await Permission.locationWhenInUse.status;
    _permissionState = status.isGranted
        ? LocationPermissionState.granted
        : LocationPermissionState.denied;
    notifyListeners();
    return status.isGranted;
  }

  Future<bool> _ensurePermission(VoidCallback onOpenSettings) async {
    if (hasPermission) return true;
    final status = await Permission.locationWhenInUse.request();
    _permissionState = status.isGranted
        ? LocationPermissionState.granted
        : LocationPermissionState.denied;
    notifyListeners();
    if (status.isGranted) return true;
    onOpenSettings();
    return false;
  }

  // ─── Paylaş ──────────────────────────────────────

  Future<void> shareLocation({
    required VoidCallback onOpenSettings,
    required void Function(double lat, double lng) onSuccess,
  }) async {
    _errorKey = null;
    _pendingAction = _PendingAction.share;
    final granted = await _ensurePermission(onOpenSettings);
    if (!granted) return;
    _pendingAction = _PendingAction.none;
    await _doGetGPS(onSuccess: onSuccess);
  }

  Future<void> _doGetGPS({
    required void Function(double lat, double lng) onSuccess,
  }) async {
    _errorKey = null;
    _isLoading = true;
    notifyListeners();
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // Reverse Geocode
      final geo = await _reverseGeocode(pos.latitude, pos.longitude);
      await _saveLocation(geo, pos.latitude, pos.longitude);

      await _markShown();
      onSuccess(pos.latitude, pos.longitude);
    } catch (_) {
      _errorKey = LocaleKeys.location_fetchError;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Konum Seç ───────────────────────────────────

  Future<void> pickOnMap({
    required VoidCallback onOpenSettings,
    required Future<void> Function() onNavigate,
  }) async {
    _pendingAction = _PendingAction.pick;
    final granted = await _ensurePermission(onOpenSettings);
    if (!granted) return;
    _pendingAction = _PendingAction.none;
    await onNavigate();
  }

  // ─── App Lifecycle: Ayarlardan Dönüş ─────────────

  Future<void> onAppResumed({
    required void Function(double lat, double lng) onShareSuccess,
    required Future<void> Function() onPickNavigate,
  }) async {
    if (_pendingAction == _PendingAction.none) return;
    final granted = await _checkCurrentPermission();
    if (!granted) {
      _pendingAction = _PendingAction.none;
      return;
    }
    final action = _pendingAction;
    _pendingAction = _PendingAction.none;
    if (action == _PendingAction.share) {
      await _doGetGPS(onSuccess: onShareSuccess);
    } else if (action == _PendingAction.pick) {
      await onPickNavigate();
    }
  }

  // ─── Seçim Tamamlandı ────────────────────────────

  Future<void> onLocationPicked(
    double lat,
    double lng,
    VoidCallback onDone, {
    String? address,
    String? city,
    String? district,
    String? neighborhood,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final _GeoResult geo;
      if (address != null) {
        geo = _GeoResult(
          addressLine: address,
          city: city ?? '',
          district: district ?? '',
          neighborhood: neighborhood ?? '',
        );
      } else {
        geo = await _reverseGeocode(lat, lng);
      }
      await _saveLocation(geo, lat, lng);
      await _markShown();
      onDone();
    } catch (_) {
      _errorKey = LocaleKeys.location_fetchError;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Nominatim Reverse Geocoding ──────────────────

  /// Lat/Lng'den Nominatim ile adres bilgilerini çeker.
  Future<_GeoResult> _reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'lat': lat.toString(),
        'lon': lng.toString(),
        'format': 'json',
        'addressdetails': '1',
        'accept-language': 'tr',
      });
      final res = await http.get(uri, headers: {'User-Agent': 'YemisApp/1.0'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final address = data['address'];
        if (address != null) {
          final province = (address['province']?.toString() ?? '')
              .replaceAll(' İli', '')
              .trim();
          final cityRaw =
              (address['city'] ?? address['town'] ?? address['village'] ?? '')
                  .toString();
          final districtClean = cityRaw.replaceAll(' İlçesi', '').trim();
          final neighborhoodClean =
              (address['suburb'] ??
                      address['neighbourhood'] ??
                      address['quarter'] ??
                      '')
                  .toString()
                  .trim();
          final road = (address['road'] ?? '').toString();
          final houseNumber = (address['house_number'] ?? '').toString();

          final details = [
            if (road.isNotEmpty) road,
            if (houseNumber.isNotEmpty) 'No: $houseNumber',
          ].join(', ');

          final parts = [
            if (province.isNotEmpty) province,
            if (districtClean.isNotEmpty) districtClean,
            if (neighborhoodClean.isNotEmpty) neighborhoodClean,
            if (details.isNotEmpty) details,
          ];

          final addressLine = (data['display_name'] ?? '').toString();

          debugPrint(
            '📍 [ReverseGeocode] city=$province | district=$districtClean | neighborhood=$neighborhoodClean',
          );

          return _GeoResult(
            addressLine: addressLine,
            city: province,
            district: districtClean,
            neighborhood: neighborhoodClean,
          );
        }
        final displayName =
            (data['display_name'] ?? 'Bilinmeyen Konum') as String;
        return _GeoResult(
          addressLine: displayName,
          city: '',
          district: '',
          neighborhood: '',
        );
      }
    } catch (_) {}
    return const _GeoResult(
      addressLine: '',
      city: '',
      district: '',
      neighborhood: '',
    );
  }

  // ─── Kayıt ───────────────────────────────────────

  Future<void> _saveLocation(_GeoResult geo, double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefAddressKey, geo.addressLine);
    await prefs.setDouble(_prefLatKey, lat);
    await prefs.setDouble(_prefLngKey, lng);

    _userSession.updateLocation(geo.addressLine, lat: lat, lng: lng);

    // API'ye gönder — city/district/neighborhood dahil
    try {
      final existingAddresses = await _authService.getAddresses();
      final isDuplicate = existingAddresses.any((a) =>
          a.addressLine.trim().toLowerCase() == geo.addressLine.trim().toLowerCase() ||
          (a.latitude == lat && a.longitude == lng));

      if (!isDuplicate) {
        await _authService.createAddress(
          AddressModel(
            id: 0,
            userId: 0,
            label: 'Ev',
            addressLine: geo.addressLine,
            city: geo.city.isNotEmpty ? geo.city : null,
            district: geo.district.isNotEmpty ? geo.district : null,
            neighborhood: geo.neighborhood.isNotEmpty ? geo.neighborhood : null,
            latitude: lat,
            longitude: lng,
            isDefault: true,
          ),
        );
        debugPrint(
          '✅ [LocationViewModel] Adres API\'ye gönderildi: ${geo.addressLine}',
        );
      } else {
        debugPrint('ℹ️ [LocationViewModel] Adres zaten mevcut, tekrar eklenmedi.');
      }
    } catch (e) {
      debugPrint('⚠️ [LocationViewModel] Adres API hatası: $e');
    }
  }

  // ─── clearError ──────────────────────────────────

  void clearError() {
    _errorKey = null;
    notifyListeners();
  }

  // ─── Yardımcı ────────────────────────────────────

  Future<void> _markShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }
}
