import 'package:flutter/material.dart';

class BusinessHomeViewModel extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
    
    debugPrint("Business Tab Selected: $index");
  }
}
