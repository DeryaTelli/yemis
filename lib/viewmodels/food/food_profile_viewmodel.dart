import 'package:flutter/material.dart';
import '../../utils/routes/app_routes.dart';

class FoodProfileViewModel extends ChangeNotifier {
  int _selectedIndex = 4;
  int get selectedIndex => _selectedIndex;


  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  /// MVVM: Alt navigasyon rotalarını ViewModel sağlar
  String? getBottomNavRoute(int index) {
    switch (index) {
      case 0: return AppRoutes.foodHome;
      case 1: return AppRoutes.foodSearch;
      case 2: return AppRoutes.home;
      case 3: return AppRoutes.foodFavorites;
      case 4: return AppRoutes.foodProfile;
      default: return null;
    }
  }
}
