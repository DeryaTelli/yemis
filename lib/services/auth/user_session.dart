import 'package:flutter/foundation.dart';
import '../../models/auth/user_model.dart';

/// Oturum açmış kullanıcının bilgilerini tutan top-level provider.
///
/// MultiProvider'a eklenir; LoginViewModel login'de [setUser] çağırır,
/// HomeView ve diğer ekranlar [currentUser] ile kullanıcı bilgisine erişir.
class UserSession extends ChangeNotifier {
  UserModel? _user;

  UserModel? get currentUser => _user;

  /// Giriş yapan kullanıcıyı kaydeder ve dinleyicileri bilgilendirir.
  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  /// Oturumu kapatır.
  void clear() {
    _user = null;
    notifyListeners();
  }

  /// Kullanıcı tipi — null ise [UserType.food] varsayılır.
  UserType get userType => _user?.userType ?? UserType.food;

  bool get isLoggedIn => _user != null;
}
