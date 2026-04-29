import 'package:flutter/material.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/auth/user_session.dart';
import '../../utils/routes/app_routes.dart';

class BusinessProfileViewModel extends ChangeNotifier {
  final IAuthService _authService;
  final UserSession _userSession;

  int _selectedIndex = 4;
  int get selectedIndex => _selectedIndex;

  BusinessProfileViewModel(this._authService, this._userSession);

  // ── Daily stats ──────────────────────────────
  int get dailySoldCount => 10;
  String get dailyTotalEarnings => '%25';

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    // API çağrısını arka planda başlatıyoruz
    _authService.logout().catchError((e) {
      debugPrint('Logout API error: $e');
    });

    // Yerel verileri temizle ve hemen yönlendir
    _userSession.clear();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  void deleteAccount(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  /// 0=BusinessHome, 1=Rezervasyon Onaylama, 2=Home(merkez), 3=Sipariş Ekle, 4=Profil
  String? getBottomNavRoute(int index) {
    switch (index) {
      case 0:
        return AppRoutes.businessHome;
      case 1:
        return AppRoutes.businessApprovals;
      case 2:
        return AppRoutes.home;
      case 3:
        return AppRoutes.businessAddOrder;
      case 4:
        return AppRoutes.businessProfile;
      default:
        return null;
    }
  }
}
