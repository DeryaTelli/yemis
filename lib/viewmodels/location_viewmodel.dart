import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/locale_keys.dart';

enum LocationPermissionState { unknown, granted, denied }

/// Kullanıcının hangi eylemi beklediğini tutar
/// (ayarlardan dönüldüğünde hangi akışın devam edeceğini bilmek için)
enum _PendingAction { none, share, pick }

class LocationViewModel extends ChangeNotifier {
  /// LoginViewModel ile aynı key — flag tek yerden okunup yazılır
  static const String _prefKey = 'location_onboarding_done';

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

  /// Açılışta sadece mevcut izin durumunu okur.
  /// İzin talebi, kullanıcı "Paylaş" veya "Konum Seç" butonuna basınca yapılır.
  Future<void> init() async {
    final status = await Permission.locationWhenInUse.status;
    _permissionState = status.isGranted
        ? LocationPermissionState.granted
        : LocationPermissionState.denied;
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

  /// Butona basıldığında izin iste; sonucu döner.
  Future<bool> _ensurePermission(VoidCallback onOpenSettings) async {
    if (hasPermission) return true;

    // İzin henüz sorulmadıysa / reddedildiyse talep et
    final status = await Permission.locationWhenInUse.request();
    _permissionState = status.isGranted
        ? LocationPermissionState.granted
        : LocationPermissionState.denied;
    notifyListeners();

    if (status.isGranted) return true;

    // Kalıcı red → ayarlara gönder (pending action set edildi)
    onOpenSettings();
    return false;
  }

  // ─── Paylaş ──────────────────────────────────────

  /// "Paylaş" butonuna basıldığında çağrılır.
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

  /// GPS'i alır ve sonucu [onSuccess] ile döner.
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

  /// "Konum Seç" butonuna basıldığında çağrılır.
  /// - İzin varsa: [onNavigate] çağırır.
  /// - İzin yoksa: Ayarlara gönderir; [_pendingAction] = pick.
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

  /// View, `WidgetsBindingObserver` ile uygulamanın ön plana döndüğünü
  /// algıladığında bu metodu çağırır.
  Future<void> onAppResumed({
    required void Function(double lat, double lng) onShareSuccess,
    required Future<void> Function() onPickNavigate,
  }) async {
    if (_pendingAction == _PendingAction.none) return;

    // İzni tekrar kontrol et (ayarlarda verilmiş olabilir)
    final granted = await _checkCurrentPermission();
    if (!granted) {
      // Hâlâ izin yok — eylemi temizle
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

  Future<void> onLocationPicked(VoidCallback onDone) async {
    await _markShown();
    onDone();
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
