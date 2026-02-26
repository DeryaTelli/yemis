import 'package:flutter/material.dart';

class FoodFavoritesViewModel extends ChangeNotifier {
  int _selectedIndex = 3;
  int get selectedIndex => _selectedIndex;



  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }
}
