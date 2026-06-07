import 'package:flutter/material.dart';
import '../../models/business/business_order_approval_model.dart';
import '../../services/business/i_business_service.dart';
import '../../utils/routes/app_routes.dart';

class BusinessApprovalsViewModel extends ChangeNotifier {
  BusinessApprovalsViewModel({required IBusinessService businessService})
    : _businessService = businessService {
    Future.microtask(loadApprovals);
  }

  final IBusinessService _businessService;

  int _selectedIndex = 1;
  int get selectedIndex => _selectedIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isConfirming = false;
  bool get isConfirming => _isConfirming;

  final List<BusinessOrderApprovalModel> _orders = [];
  List<BusinessOrderApprovalModel> get orders => List.unmodifiable(_orders);

  BusinessOrderApprovalModel? _matchedOrder;
  BusinessOrderApprovalModel? get matchedOrder => _matchedOrder;

  Future<void> loadApprovals() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final approvals = await _businessService.getOrderApprovals();
      _orders
        ..clear()
        ..addAll(approvals);
      if (_matchedOrder != null &&
          !_orders.any((order) => order.id == _matchedOrder!.id)) {
        _matchedOrder = null;
      }
    } catch (e) {
      _error = 'Siparişler yüklenemedi. Lütfen tekrar deneyin.';
      _orders.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool matchQr(String rawValue) {
    if (_isConfirming) return false;
    for (final order in _orders) {
      if (order.matchesScan(rawValue)) {
        _matchedOrder = order;
        _error = null;
        notifyListeners();
        return true;
      }
    }
    _error = 'Bu QR kod bekleyen siparişlerinizle eşleşmedi.';
    notifyListeners();
    return false;
  }

  Future<bool> confirmPickup() async {
    final order = _matchedOrder;
    if (order == null || _isConfirming) return false;
    _isConfirming = true;
    _error = null;
    notifyListeners();

    final success = await _businessService.confirmOrderPickup(order.id);
    if (success) {
      _orders.removeWhere((item) => item.id == order.id);
      _matchedOrder = null;
    } else {
      _error = 'Teslim onaylanamadı. Lütfen tekrar deneyin.';
    }
    _isConfirming = false;
    notifyListeners();
    return success;
  }

  void clearMatch() {
    _matchedOrder = null;
    _error = null;
    notifyListeners();
  }

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  String? getBottomNavRoute(int index) {
    switch (index) {
      case 0:
        return AppRoutes.businessHome;
      case 1:
        return AppRoutes.businessApprovals;
      case 2:
        return AppRoutes.home;
      case 3:
        return AppRoutes.businessAddOrder;
      case 4:
        return AppRoutes.businessProfile;
      default:
        return null;
    }
  }
}
