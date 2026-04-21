import 'package:flutter/foundation.dart';
import '../../models/auth/user_model.dart';

/// Oturum açmış kullanıcının bilgilerini ve mevcut konum bilgisini tutan provider.
class UserSession extends ChangeNotifier {
  UserModel? _user;
  String? _token;
  String? _currentAddress;
  double? _currentLat;
  double? _currentLng;

  UserModel? get currentUser => _user;
  String? get token => _token;
  String? get currentAddress => _currentAddress;
  double? get currentLat => _currentLat;
  double? get currentLng => _currentLng;

  /// Giriş yapan kullanıcıyı kaydeder ve dinleyicileri bilgilendirir.
  void setUser(UserModel user, {String? token}) {
    _user = user;
    _token = token;
    notifyListeners();
  }

  /// Mevcut konumu günceller.
  void updateLocation(String address, {double? lat, double? lng}) {
    _currentAddress = address;
    _currentLat = lat;
    _currentLng = lng;
    notifyListeners();
  }

  /// Oturumu kapatır.
  void clear() {
    _user = null;
    _token = null;
    _currentAddress = null;
    _currentLat = null;
    _currentLng = null;
    notifyListeners();
  }

  /// Kullanıcı tipi — null ise [UserType.food] varsayılır.
  UserType get userType => _user?.userType ?? UserType.food;

  bool get isLoggedIn => _user != null;
}
