import 'package:flutter/material.dart';

class VolunteerProfileViewModel extends ChangeNotifier {
  int _selectedIndex = 4;
  int get selectedIndex => _selectedIndex;

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }
}
