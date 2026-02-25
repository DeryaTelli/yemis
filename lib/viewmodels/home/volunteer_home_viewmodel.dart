import 'package:flutter/material.dart';

class VolunteerHomeViewModel extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
    
    debugPrint("Volunteer Tab Selected: $index");
  }
}
