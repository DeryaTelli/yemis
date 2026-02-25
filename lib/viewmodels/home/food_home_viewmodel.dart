import 'package:flutter/material.dart';

class FoodHomeViewModel extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
    
    // Yönlendirme mantığı buraya eklenebilir
    debugPrint("Food Tab Selected: $index");
  }
}
