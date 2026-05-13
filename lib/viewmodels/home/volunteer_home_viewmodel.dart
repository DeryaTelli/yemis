import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:yemis/models/volunteer/volunteer_listing.dart';
import 'package:yemis/services/auth/user_session.dart';
import 'package:yemis/services/volunteer/i_volunteer_service.dart';
import 'package:yemis/utils/routes/app_routes.dart';

/// VolunteerHome ekranının ViewModel'i.
class VolunteerHomeViewModel extends ChangeNotifier {
  VolunteerHomeViewModel({
    required UserSession userSession,
    required IVolunteerService volunteerService,
  })  : _userSession = userSession,
        _service = volunteerService {
    _userSession.addListener(_onUserSessionChanged);
    init();
  }

  final IVolunteerService _service;
  final UserSession _userSession;

  // ─── State ────────────────────────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<VolunteerListing> _allListings = [];
  List<VolunteerListing> get listings => filteredListings;

  List<VolunteerListing> _activeTasks = [];
  List<VolunteerListing> get activeTasks => _activeTasks;

  VolunteerListing? _pendingReviewTask;
  VolunteerListing? get pendingReviewTask => _pendingReviewTask;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  String get appBarTitle {
    final addr = _userSession.currentAddress;
    if (addr != null && addr.isNotEmpty) return addr;
    return LocaleKeys.common_selectLocation.tr();
  }

  Color get appBarColor => const Color(0xFF22B05A); // AppColors.volunteerColor

  double? get userLat => _userSession.currentLat;
  double? get userLng => _userSession.currentLng;

  // ─── Init ─────────────────────────────────────────────

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      _fetchListings(),
      _fetchActiveTasks(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchListings() async {
    try {
      final results = await _service.getFeaturedListings(
        lat: _userSession.currentLat,
        lng: _userSession.currentLng,
        radius: 10000,
      );

      var sortedListings = List<VolunteerListing>.from(results);

      // Konuma göre sırala (Eğer kullanıcı konumu varsa)
      if (_userSession.currentLat != null && _userSession.currentLng != null) {
        sortedListings.sort((a, b) {
          if (a.latitude == null || a.longitude == null) return 1;
          if (b.latitude == null || b.longitude == null) return -1;

          final distA = (a.latitude! - _userSession.currentLat!) * (a.latitude! - _userSession.currentLat!) +
                        (a.longitude! - _userSession.currentLng!) * (a.longitude! - _userSession.currentLng!);
          final distB = (b.latitude! - _userSession.currentLat!) * (b.latitude! - _userSession.currentLat!) +
                        (b.longitude! - _userSession.currentLng!) * (b.longitude! - _userSession.currentLng!);
          return distA.compareTo(distB);
        });
      }

      // İlanlara bölüm ataması yapalım
      _allListings = sortedListings.asMap().entries.map((entry) {
        final index = entry.key;
        final listing = entry.value;
        
        // İlk 10 ilan yakında (horizontal scroll için), kalanlar popüler
        return listing.copyWith(
          section: index < 10 ? VolunteerSection.nearYou : VolunteerSection.todayPopular,
        );
      }).toList();

    } catch (e) {
      debugPrint('Error fetching home listings: $e');
    }
  }

  Future<void> _fetchActiveTasks() async {
    try {
      final tasks = await _service.getAttendedListings();
      final now = DateTime.now();

      // Sadece tamamlanmamış ve süresi geçmemiş olanları aktif task olarak kabul et
      // Not: Eğer ilan alınmışsa (pickedUp/onTheWay), süresi geçse bile teslim etmesi için gösteriyoruz.
      _activeTasks = tasks.where((t) {
        // Zaten tamamlanmışsa gösterme
        if (t.isAttended && t.deliveryStatus == DeliveryStatus.completed) return false;

        // Süresi dolmuş mu kontrolü
        final isExpired = t.pickupEndTime != null && t.pickupEndTime!.isBefore(now);
        
        // Eğer süresi dolmuşsa ve henüz ilanı almamışsa (pending veya yola çıkma aşaması) gösterme
        if (isExpired && (t.deliveryStatus == DeliveryStatus.pending || t.deliveryStatus == DeliveryStatus.onTheWayToPickUp)) {
          return false;
        }

        return true;
      }).toList();
    } catch (e) {
      debugPrint('Error fetching active tasks: $e');
    }
  }

  // ─── Task Actions ─────────────────────────────────────

  /// Teslimat durumunu bir sonraki adıma taşır (Yerel)
  void updateTaskStatus(String taskId, DeliveryStatus newStatus) {
    final index = _activeTasks.indexWhere((t) => t.taskId == taskId);
    if (index != -1) {
      _activeTasks[index] = _activeTasks[index].copyWith(deliveryStatus: newStatus);
      notifyListeners();
    }
  }

  /// Görevi tamamla (Backend API)
  Future<void> completeVolunteerTask(String taskId) async {
    final taskIndex = _activeTasks.indexWhere((t) => t.taskId == taskId);
    if (taskIndex == -1) return;

    final task = _activeTasks[taskIndex];
    _isLoading = true;
    notifyListeners();

    final success = await _service.completeTask(int.parse(taskId));
    if (success) {
      // Aktiflerden çıkar, inceleme bekleyenlere ekle
      _activeTasks.removeAt(taskIndex);
      _pendingReviewTask = task.copyWith(deliveryStatus: DeliveryStatus.completed);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Görevi iptal et (Backend API)
  Future<void> cancelVolunteerTask(String taskId) async {
    _isLoading = true;
    notifyListeners();

    final success = await _service.cancelTask(int.parse(taskId));
    if (success) {
      _activeTasks.removeWhere((t) => t.taskId == taskId);
      // İlanları da tazele ki iptal edilen ilan geri gelsin
      await _fetchListings();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Yorum yapıldıktan sonra kartı kaldırır
  void onReviewSubmitted() {
    _pendingReviewTask = null;
    notifyListeners();
  }

  void _onUserSessionChanged() {
    // Konum değiştiyse yeniden çek
    init();
  }

  // ─── Arama ────────────────────────────────────────────

  void onSearchChanged(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ─── Filtrelenmiş İlanlar ─────────────────────────────

  List<VolunteerListing> get filteredListings {
    var list = _allListings;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((l) {
        return l.title.toLowerCase().contains(q) ||
            l.userName.toLowerCase().contains(q) ||
            l.location.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  // ─── Bottom Navigation ────────────────────────────────

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
    debugPrint("Volunteer Tab Selected: $index");
  }

  String? getBottomNavRoute(int index) {
    switch (index) {
      case 0:
        return AppRoutes.volunteerHome;
      case 2:
        return AppRoutes.home;
      case 1:
        return AppRoutes.volunteerSearch;
      case 3:
        return AppRoutes.volunteerAddListing;
      case 4:
        return AppRoutes.volunteerProfile;
      default:
        return null;
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _userSession.removeListener(_onUserSessionChanged);
    super.dispose();
  }
}

