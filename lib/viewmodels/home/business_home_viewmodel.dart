import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../services/auth/user_session.dart';
import '../../utils/routes/app_routes.dart';

class BusinessHomeViewModel extends ChangeNotifier {
  BusinessHomeViewModel({required UserSession userSession}) : _userSession = userSession {
    _userSession.addListener(_onUserSessionChanged);
  }

  final UserSession _userSession;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  String get appBarTitle {
    final addr = _userSession.currentAddress;
    if (addr != null && addr.isNotEmpty) return addr;
    return LocaleKeys.common_selectLocation.tr();
  }

  Color get appBarColor => const Color(0xFFFE8800);
  
  String? get profileImageUrl => _userSession.currentUser?.imageUrl;

  /// Mock haftalık satış verileri (Pzt → Paz)
  List<double> get weeklySales => [45, 70, 30, 90, 120, 80, 60];

  /// Satılan siparişler sayesinde önlenen CO₂ oranı (0.0 – 1.0)
  double get co2SavedPercent => 0.80;

  void _onUserSessionChanged() {
    notifyListeners();
  }

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
    debugPrint("Business Tab Selected: $index");
  }

  /// 0=BusinessHome, 1=Rezervasyon Onaylama, 2=Home(merkez), 3=Sipariş Ekle, 4=Profil
  String? getBottomNavRoute(int index) {
    switch (index) {
      case 0:
        return AppRoutes.businessHome;
      case 2:
        return AppRoutes.home;
      case 1:
        return AppRoutes.businessApprovals;
      case 3:
        return AppRoutes.businessAddOrder;
      case 4:
        return AppRoutes.businessProfile;
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _userSession.removeListener(_onUserSessionChanged);
    super.dispose();
  }
}
