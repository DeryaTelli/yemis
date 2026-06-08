import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../services/auth/user_session.dart';
import '../../services/business/i_business_service.dart';
import '../../utils/routes/app_routes.dart';
import '../../models/business/business_dashboard_model.dart';
import '../../models/business/business_insight_model.dart';

class BusinessHomeViewModel extends ChangeNotifier {
  BusinessHomeViewModel({
    required UserSession userSession,
    required IBusinessService businessService,
  })  : _userSession = userSession,
        _businessService = businessService {
    _userSession.addListener(_onUserSessionChanged);
    Future.microtask(() => init());
  }

  final UserSession _userSession;
  final IBusinessService _businessService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  BusinessDashboardModel? _dashboardStats;
  BusinessInsightModel? _businessInsight;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  String get appBarTitle {
    final addr = _userSession.currentAddress;
    if (addr != null && addr.isNotEmpty) return addr;
    return LocaleKeys.common_selectLocation.tr();
  }

  Color get appBarColor => const Color(0xFFFE8800);
  
  String? get profileImageUrl => _userSession.currentUser?.imageUrl;

  /// Haftalık satış verileri (API'den gelir)
  List<double> get weeklySales => _dashboardStats?.weeklySales ?? [0, 0, 0, 0, 0, 0, 0];

  /// Satılan siparişler sayesinde önlenen CO₂ oranı (0.0 – 1.0)
  double get co2SavedPercent => (_dashboardStats?.co2Saved ?? 0.0) / 100.0;

  BusinessInsightModel? get businessInsight => _businessInsight;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _dashboardStats = await _businessService.getDashboardStats();
    _businessInsight = await _businessService.getBusinessInsights();

    _isLoading = false;
    notifyListeners();
  }

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
