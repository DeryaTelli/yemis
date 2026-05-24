import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/business/reservation_model.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../services/volunteer/i_volunteer_service.dart';
import '../../utils/routes/app_routes.dart';

/// Business rezervasyon/onay ekraninin ViewModel'i.
class BusinessApprovalsViewModel extends ChangeNotifier {
  BusinessApprovalsViewModel({required IVolunteerService volunteerService})
    : _volunteerService = volunteerService {
    Future.microtask(loadApprovals);
  }

  final IVolunteerService _volunteerService;

  int _selectedIndex = 1;
  int get selectedIndex => _selectedIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  final List<ReservationModel> _reservations = [];
  final Set<String> _approvedIds = {};
  final Set<String> _rejectedIds = {};
  final Set<String> _processingIds = {};

  List<ReservationModel> get reservations => List.unmodifiable(_reservations);

  bool isApproved(String id) => _approvedIds.contains(id);
  bool isRejected(String id) => _rejectedIds.contains(id);
  bool isPending(String id) => !isApproved(id) && !isRejected(id);
  bool isProcessing(String id) => _processingIds.contains(id);

  Future<void> loadApprovals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final listings = await _volunteerService.getOwnerVolunteerTasks();
      _reservations
        ..clear()
        ..addAll(
          listings
              .where(_isPendingOwnerApproval)
              .map(_toReservation)
              .where((reservation) => reservation.id.isNotEmpty),
        );
    } catch (e) {
      _error = e.toString();
      _reservations.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isPendingOwnerApproval(VolunteerListing listing) {
    final ownerStatus = listing.ownerProgress?.status?.toLowerCase();
    final ownerActions =
        listing.ownerProgress?.availableActions
            .map((action) => action.toLowerCase())
            .toSet() ??
        const <String>{};
    return listing.deliveryStatus == DeliveryStatus.pendingOwnerApproval ||
        ownerStatus == 'pending_owner_approval' ||
        (ownerActions.contains('approve') && ownerActions.contains('reject'));
  }

  ReservationModel _toReservation(VolunteerListing listing) {
    final start = listing.pickupStartTime;
    final end = listing.pickupEndTime;
    final listingDate = end != null
        ? DateFormat('dd.MM.yyyy').format(end)
        : start != null
        ? DateFormat('dd.MM.yyyy').format(start)
        : '-';
    final timeWindow = start != null && end != null
        ? '${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}'
        : listing.timeRange;

    return ReservationModel(
      id: listing.taskId ?? listing.id,
      listingTitle: listing.title,
      listingDate: listingDate,
      timeWindow: timeWindow,
      orderedCount: 1,
      totalCount: 1,
      customerName:
          listing.assignedVolunteerName ?? listing.volunteerName ?? 'Gonullu',
      foodImageUrl: listing.imageUrl.isNotEmpty ? listing.imageUrl : null,
    );
  }

  Future<void> approve(String id) async {
    if (_processingIds.contains(id)) return;
    _processingIds.add(id);
    notifyListeners();

    final success = await _volunteerService.acceptVolunteer(int.parse(id));
    _processingIds.remove(id);
    if (success) {
      _approvedIds.add(id);
      _rejectedIds.remove(id);
      _reservations.removeWhere((reservation) => reservation.id == id);
      _error = null;
    } else {
      _error = 'Gonullu onaylanamadi.';
    }
    notifyListeners();
  }

  Future<void> reject(String id) async {
    if (_processingIds.contains(id)) return;
    _processingIds.add(id);
    notifyListeners();

    final success = await _volunteerService.rejectVolunteer(int.parse(id));
    _processingIds.remove(id);
    if (success) {
      _rejectedIds.add(id);
      _approvedIds.remove(id);
      _reservations.removeWhere((reservation) => reservation.id == id);
      _error = null;
    } else {
      _error = 'Gonullu reddedilemedi.';
    }
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
