import 'package:flutter/material.dart';
import '../../models/business/business_listing_model.dart';
import '../../services/business/i_business_service.dart';

class BusinessListingDetailViewModel extends ChangeNotifier {
  final IBusinessService? _businessService;
  BusinessListingModel _listing;
  bool _isDisposed = false;

  BusinessListingDetailViewModel({
    IBusinessService? businessService,
    required BusinessListingModel listing,
  })  : _businessService = businessService,
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

  BusinessListingModel get listing => _listing;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> refreshListing() async {
    if (_businessService == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final bags = await _businessService!.getMyBags();
      final updated = bags.firstWhere((element) => element.id == _listing.id, orElse: () => _listing);
      _listing = updated;
    } catch (e) {
      debugPrint('Error refreshing listing detail: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
