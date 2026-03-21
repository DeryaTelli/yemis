import 'package:flutter/material.dart';
import '../../models/business/reservation_model.dart';
import '../../utils/routes/app_routes.dart';

/// Business rezervasyon onaylama ekranının ViewModel'i.
class BusinessApprovalsViewModel extends ChangeNotifier {
  // ─── Nav ──────────────────────────────────────────────
  int _selectedIndex = 1;
  int get selectedIndex => _selectedIndex;

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

  // ─── Rezervasyonlar ────────────────────────────────────
  final List<ReservationModel> _reservations = [
    const ReservationModel(
      id: 'r1',
      listingDate: '12/01/2026',
      timeWindow: '15.30-19.00',
      orderedCount: 1,
      totalCount: 5,
      customerName: 'Derya Telli',
      foodImageUrl: null, // network URL buraya eklenebilir
    ),
    const ReservationModel(
      id: 'r2',
      listingDate: '12/01/2026',
      timeWindow: '10.00-12.00',
      orderedCount: 2,
      totalCount: 8,
      customerName: 'Ahmet Yılmaz',
      foodImageUrl: null,
    ),
  ];

  List<ReservationModel> get reservations =>
      List.unmodifiable(_reservations);

  // ─── Onay / Red ───────────────────────────────────────
  final Set<String> _approvedIds = {};
  final Set<String> _rejectedIds = {};

  bool isApproved(String id) => _approvedIds.contains(id);
  bool isRejected(String id) => _rejectedIds.contains(id);
  bool isPending(String id) => !isApproved(id) && !isRejected(id);

  void approve(String id) {
    _approvedIds.add(id);
    _rejectedIds.remove(id);
    notifyListeners();
  }

  void reject(String id) {
    _rejectedIds.add(id);
    _approvedIds.remove(id);
    notifyListeners();
  }
}
