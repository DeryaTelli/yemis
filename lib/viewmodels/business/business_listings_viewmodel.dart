import 'package:flutter/material.dart';
import '../../models/business/business_listing_model.dart';
import '../../services/business/i_business_service.dart';
import '../../utils/routes/app_routes.dart';

enum ListingType { all, sold, active, expired }

class BusinessListingsViewModel extends ChangeNotifier {
  final IBusinessService? _businessService;
  final ListingType type;
  bool _isDisposed = false;

  BusinessListingsViewModel({
    IBusinessService? businessService,
    this.type = ListingType.all,
  }) : _businessService = businessService;

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

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<BusinessListingModel> _listings = [];
  List<BusinessListingModel> get listings => _listings;

  Future<void> fetchListings() async {
    if (_businessService == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      switch (type) {
        case ListingType.all:
          _listings = await _businessService!.getMyBags();
          break;
        case ListingType.sold:
          // Sadece stoku bitenler
          final allSoldOrExpired = await _businessService!.getMySoldBags();
          _listings = allSoldOrExpired.where((item) => item.isSold).toList();
          break;
        case ListingType.active:
          _listings = await _businessService!.getMyUnsoldBags();
          break;
        case ListingType.expired:
          // Stoku olup süresi dolanlar
          final allSoldOrExpired = await _businessService!.getMySoldBags();
          _listings = allSoldOrExpired.where((item) => !item.isSold && item.isExpired).toList();
          break;
      }
    } catch (e) {
      debugPrint('Error fetching listings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteListing(int id) async {
    if (_businessService == null) {
      debugPrint('Error: BusinessService is null in ViewModel');
      return false;
    }

    debugPrint('--- VM DELETE REQUEST ---');
    debugPrint('Listing ID: $id');
    
    try {
      final success = await _businessService!.deleteBag(id);
      debugPrint('VM Delete Success: $success');
      
      if (success) {
        _listings.removeWhere((item) => item.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting listing in VM: $e');
    }
    return false;
  }

  void editListing(BuildContext context, BusinessListingModel item) {
    Navigator.pushNamed(
      context,
      AppRoutes.businessEditOrder,
      arguments: item,
    ).then((result) {
      if (result == true) {
        fetchListings(); // Güncelleme sonrası listeyi yenile
      }
    });
  }

  void navigateToDetail(BuildContext context, BusinessListingModel item) {
    Navigator.pushNamed(
      context,
      AppRoutes.businessListingDetail,
      arguments: item,
    );
  }
}
