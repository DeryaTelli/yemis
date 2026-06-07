import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/auth/user_model.dart';

/// Oturum açmış kullanıcının bilgilerini ve mevcut konum bilgisini tutan provider.
class UserSession extends ChangeNotifier {
  UserModel? _user;
  String? _token;
  String? _currentAddress;
  double? _currentLat;
  double? _currentLng;
  bool _shouldPersist =
      true; // Varsayılan olarak true (geriye dönük uyumluluk için)
  bool _notificationScheduled = false;

  UserModel? get currentUser => _user;
  String? get token => _token;
  String? get currentAddress => _currentAddress;
  double? get currentLat => _currentLat;
  double? get currentLng => _currentLng;
  bool get shouldPersist => _shouldPersist;

  /// SharedPreferences anahtarları
  static const String _userKey = 'auth_user';
  static const String _tokenKey = 'auth_token';
  static const String _addressKey = 'current_location_address';
  static const String _latKey = 'current_lat';
  static const String _lngKey = 'current_lng';
  static const String _persistKey = 'auth_persist';

  void _notifyListenersSafely() {
    if (!hasListeners) return;

    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      notifyListeners();
      return;
    }

    if (_notificationScheduled) return;
    _notificationScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _notificationScheduled = false;
      if (hasListeners) notifyListeners();
    });
  }

  /// Kayıtlı oturumu yükler.
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        _user = UserModel.fromJson(jsonDecode(userJson));
      } catch (e) {
        debugPrint('UserSession: Error decoding user: $e');
      }
    }

    _token = prefs.getString(_tokenKey);
    _currentAddress = prefs.getString(_addressKey);
    _currentLat = prefs.getDouble(_latKey);
    _currentLng = prefs.getDouble(_lngKey);
    _shouldPersist = prefs.getBool(_persistKey) ?? true;

    _notifyListenersSafely();
  }

  /// Giriş yapan kullanıcıyı kaydeder ve dinleyicileri bilgilendirir.
  /// [persist] false ise bilgiler sadece bellekte tutulur, SharedPreferences'a yazılmaz.
  void setUser(UserModel user, {String? token, bool? persist}) {
    _user = user;
    if (persist != null) {
      _shouldPersist = persist;
    }
    // Sadece yeni bir token gelmişse mevcut olanı güncelle.
    // Profil güncellemelerinde token null gelirse mevcut olanı koruyoruz.
    if (token != null && token.isNotEmpty) {
      _token = token;
    }
    _notifyListenersSafely();

    // Sadece persist true ise sakla
    if (_shouldPersist) {
      _persistUser(user, _token);
    } else {
      // Eğer persist false ise ve daha önce kayıtlı veri varsa temizle
      _clearPersistedSession();
    }
  }

  Future<void> _persistUser(UserModel user, String? token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    if (token != null && token.isNotEmpty) {
      await prefs.setString(_tokenKey, token);
    }
    await prefs.setBool(_persistKey, true);
  }

  /// Mevcut konumu günceller ve dinleyicileri bilgilendirir.
  /// Arka planda kalıcı belleğe yazar.
  void updateLocation(String address, {double? lat, double? lng}) {
    _currentAddress = address;
    if (lat != null) _currentLat = lat;
    if (lng != null) _currentLng = lng;
    _notifyListenersSafely();

    _persistLocation(address, lat, lng);
  }

  Future<void> _persistLocation(
    String address,
    double? lat,
    double? lng,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_addressKey, address);
    if (lat != null) await prefs.setDouble(_latKey, lat);
    if (lng != null) await prefs.setDouble(_lngKey, lng);
  }

  /// Oturumu kapatır ve dinleyicileri bilgilendirir.
  /// Arka planda kalıcı belleği temizler.
  void clear() {
    _user = null;
    _token = null;
    _currentAddress = null;
    _currentLat = null;
    _currentLng = null;
    _notifyListenersSafely();

    _clearPersistedSession();
  }

  Future<void> _clearPersistedSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_addressKey);
    await prefs.remove(_latKey);
    await prefs.remove(_lngKey);
    await prefs.remove(_persistKey);
  }

  /// Kullanıcı tipi — null ise [UserType.food] varsayılır.
  UserType get userType => _user?.userType ?? UserType.food;

  bool get isLoggedIn => _user != null && _token != null;
}
