import 'package:flutter/material.dart';

class VolunteerAddListingViewModel extends ChangeNotifier {
  int _selectedIndex = 3; // Index for Add Listing in Volunteer module
  int get selectedIndex => _selectedIndex;

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }
}
