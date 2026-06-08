import 'package:flutter/material.dart';
import '../../models/business/business_dashboard_model.dart';
import '../../models/business/business_insight_model.dart';
import '../../services/business/i_business_service.dart';

class BusinessReportsViewModel extends ChangeNotifier {
  final IBusinessService _businessService;
  bool _isDisposed = false;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  BusinessDashboardModel? _stats;
  BusinessDashboardModel? get stats => _stats;

  BusinessInsightModel? _businessInsight;
  BusinessInsightModel? get businessInsight => _businessInsight;

  BusinessReportsViewModel(this._businessService) {
    Future.microtask(() => fetchStats());
  }

  Future<void> fetchStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stats = await _businessService.getDashboardStats();
      _businessInsight = await _businessService.getBusinessInsights();
    } catch (e) {
      debugPrint('Error fetching business stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(Duration.zero, () {
        if (!_isDisposed) super.notifyListeners();
      });
    });
    WidgetsBinding.instance.scheduleFrame();
  }
}
