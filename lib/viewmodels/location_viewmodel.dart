import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth/user_session.dart';
import '../../utils/locale_keys.dart';

enum LocationPermissionState { unknown, granted, denied }

enum _PendingAction { none, share, pick }

class LocationViewModel extends ChangeNotifier {
  LocationViewModel({required UserSession userSession}) : _userSession = userSession;

  final UserSession _userSession;

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

  bool get hasPermission =>
      _permissionState == LocationPermissionState.granted;

  _PendingAction _pendingAction = _PendingAction.none;

  // ─── Init ─────────────────────────────────────────

  Future<void> init() async {
    final status = await Permission.locationWhenInUse.status;
    _permissionState = status.isGranted
        ? LocationPermissionState.granted
        : LocationPermissionState.denied;
    
    // Yüklü lokasyonu SharedPreferences'dan oku
    final prefs = await SharedPreferences.getInstance();
    final savedAddress = prefs.getString(_prefAddressKey);
    final savedLat = prefs.getDouble(_prefLatKey);
    final savedLng = prefs.getDouble(_prefLngKey);

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
      final address = await _reverseGeocode(pos.latitude, pos.longitude);
      await _saveLocation(address, pos.latitude, pos.longitude);
      
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

  Future<void> onLocationPicked(double lat, double lng, VoidCallback onDone) async {
    _isLoading = true;
    notifyListeners();
    try {
      final address = await _reverseGeocode(lat, lng);
      await _saveLocation(address, lat, lng);
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

  Future<String> _reverseGeocode(double lat, double lng) async {
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
          final city = address['city'] ?? address['town'] ?? address['village'] ?? address['suburb'] ?? '';
          final road = address['road'] ?? '';
          if (city.isNotEmpty && road.isNotEmpty) {
            return '$city, $road';
          } else if (city.isNotEmpty) {
            return city;
          }
        }
        return data['display_name'] ?? 'Bilinmeyen Konum';
      }
    } catch (_) {}
    return 'Karabük, Merkez'; // Fallback
  }

  // ─── Kayıt ───────────────────────────────────────

  Future<void> _saveLocation(String address, double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefAddressKey, address);
    await prefs.setDouble(_prefLatKey, lat);
    await prefs.setDouble(_prefLngKey, lng);
    
    _userSession.updateLocation(address, lat: lat, lng: lng);
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
