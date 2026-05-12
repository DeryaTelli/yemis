import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:yemis/models/notification/notification_model.dart';
import 'package:yemis/services/notifications/api_notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final ApiNotificationService _service;

  List<NotificationModel> _notifications = [];
  NotificationPreferences _preferences = const NotificationPreferences();
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _isPrefsLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  NotificationPreferences get preferences => _preferences;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isPrefsLoading => _isPrefsLoading;
  String? get error => _error;

  NotificationViewModel(this._service);

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getMyNotifications(),
        _service.getUnreadCount(),
      ]);
      _notifications = results[0] as List<NotificationModel>;
      _unreadCount = results[1] as int;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPreferences() async {
    _isPrefsLoading = true;
    notifyListeners();
    final prefs = await _service.getPreferences();
    if (prefs != null) _preferences = prefs;
    _isPrefsLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int notificationId) async {
    final success = await _service.markAsRead(notificationId);
    if (success) {
      _notifications = _notifications.map((n) {
        if (n.id == notificationId) return n.copyWith(isRead: true);
        return n;
      }).toList();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final success = await _service.markAllAsRead();
    if (success) {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    final success = await _service.deleteNotification(notificationId);
    if (success) {
      _notifications.removeWhere((n) => n.id == notificationId);
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    }
  }

  Future<void> updatePreferences(NotificationPreferences prefs) async {
    _isPrefsLoading = true;
    notifyListeners();
    final updated = await _service.updatePreferences(prefs);
    if (updated != null) _preferences = updated;
    _isPrefsLoading = false;
    notifyListeners();
  }

  /// Returns a relative human-readable time string or date
  String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDate =
        DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (notificationDate == today) {
      return 'Bugün';
    }
    return DateFormat('dd.MM.yyyy').format(dateTime);
  }

  /// Icon for notification type
  static Map<String, dynamic> iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'volunteer':
        return {'icon': 'volunteer_activism', 'color': 'volunteer'};
      case 'order':
        return {'icon': 'shopping_basket', 'color': 'food'};
      case 'promotion':
        return {'icon': 'local_offer', 'color': 'food'};
      case 'system':
        return {'icon': 'settings', 'color': 'grey'};
      default:
        return {'icon': 'notifications', 'color': 'primary'};
    }
  }
}
