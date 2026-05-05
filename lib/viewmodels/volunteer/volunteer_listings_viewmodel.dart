import 'package:flutter/material.dart';
import 'package:yemis/utils/routes/app_routes.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../services/volunteer/i_volunteer_service.dart';
import '../../services/volunteer/mock_volunteer_service.dart';

enum VolunteerListingType { active, past, attended }

class VolunteerListingsViewModel extends ChangeNotifier {
  final VolunteerListingType type;
  final IVolunteerService _volunteerService;

  VolunteerListingsViewModel({
    required this.type,
    required IVolunteerService volunteerService,
  }) : _volunteerService = volunteerService;

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

  Future<bool> deleteListing(String id) async {
    try {
      final success = await _volunteerService.deleteMeal(int.parse(id));
      if (success) {
        _listings.removeWhere((element) => element.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error deleting volunteer listing: $e');
      return false;
    }
  }

  Future<void> editListing(
    BuildContext context,
    VolunteerListing listing,
  ) async {
    final result = await Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed(AppRoutes.volunteerEditListing, arguments: listing);
    if (result == true) {
      fetchListings();
    }
  }
}
