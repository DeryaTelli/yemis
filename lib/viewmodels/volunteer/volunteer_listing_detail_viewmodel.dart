import 'package:flutter/material.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../services/volunteer/i_volunteer_service.dart';

class VolunteerListingDetailViewModel extends ChangeNotifier {
  final IVolunteerService? _volunteerService;
  VolunteerListing _listing;
  bool _isDisposed = false;

  VolunteerListingDetailViewModel({
    IVolunteerService? volunteerService,
    required VolunteerListing listing,
  })  : _volunteerService = volunteerService,
        _listing = listing;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  VolunteerListing get listing => _listing;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> refreshListing() async {
    if (_volunteerService == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _volunteerService!.getVolunteerDetail(_listing.id);
      _listing = updated;
    } catch (e) {
      debugPrint('Error refreshing volunteer listing detail: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> acceptVolunteer() async {
    if (_volunteerService == null || _listing.taskId == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _volunteerService!.acceptVolunteer(int.parse(_listing.taskId!));
      if (success) {
        await refreshListing();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rejectVolunteer() async {
    if (_volunteerService == null || _listing.taskId == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _volunteerService!.rejectVolunteer(int.parse(_listing.taskId!));
      if (success) {
        await refreshListing();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> ownerHandover() async {
    if (_volunteerService == null || _listing.taskId == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _volunteerService!.ownerHandover(int.parse(_listing.taskId!));
      if (success) {
        await refreshListing();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmDelivery() async {
    if (_volunteerService == null || _listing.taskId == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _volunteerService!.confirmDelivery(int.parse(_listing.taskId!));
      if (success) {
        await refreshListing();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitOwnerReview(Map<String, dynamic> data) async {
    if (_volunteerService == null || _listing.taskId == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _volunteerService!.submitOwnerReview(int.parse(_listing.taskId!), data);
      if (success) {
        await refreshListing();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
