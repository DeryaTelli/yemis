import 'package:flutter/material.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../services/volunteer/i_volunteer_service.dart';
import '../../services/volunteer/mock_volunteer_service.dart';

enum VolunteerListingType { active, past, attended }

class VolunteerListingsViewModel extends ChangeNotifier {
  final VolunteerListingType type;
  final IVolunteerService _volunteerService = MockVolunteerService();

  VolunteerListingsViewModel({required this.type});

  List<VolunteerListing> _listings = [];
  List<VolunteerListing> get listings => _listings;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchListings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      switch (type) {
        case VolunteerListingType.active:
          _listings = await _volunteerService.getActiveListings();
          break;
        case VolunteerListingType.past:
          _listings = await _volunteerService.getPastListings();
          break;
        case VolunteerListingType.attended:
          _listings = await _volunteerService.getAttendedListings();
          break;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
