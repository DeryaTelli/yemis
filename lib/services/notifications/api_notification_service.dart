import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../common/intercepted_client.dart';
import 'package:yemis/models/notification/notification_model.dart';
import 'package:yemis/utils/constants/api_constants.dart';

class ApiNotificationService {
  final http.Client _client = InterceptedClient();
  String? _authToken;

  void setToken(String? token) => _authToken = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  void _log(String label, String url, {int? statusCode, String? body}) {
    debugPrint('--- API REQUEST ($label) ---');
    debugPrint('URL: $url');
    if (statusCode != null) debugPrint('Status Code: $statusCode');
    if (body != null) debugPrint('Body: $body');
    debugPrint('------------------------------');
  }

  // GET /api/notifications/my
  Future<List<NotificationModel>> getMyNotifications() async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.notifications}';
    _log('GET NOTIFICATIONS', url);
    try {
      final response = await _client
          .get(Uri.parse(url), headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      _log('GET NOTIFICATIONS', url, statusCode: response.statusCode, body: response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => NotificationModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('getMyNotifications error: $e');
    }
    return [];
  }

  // GET /api/notifications/unread-count
  Future<int> getUnreadCount() async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.notificationsUnreadCount}';
    try {
      final response = await _client
          .get(Uri.parse(url), headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['unread_count'] as int? ?? 0;
      }
    } catch (e) {
      debugPrint('getUnreadCount error: $e');
    }
    return 0;
  }

  // PUT /api/notifications/{notification_id}/read
  Future<bool> markAsRead(int notificationId) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.notificationRead(notificationId)}';
    try {
      final response = await _client
          .put(Uri.parse(url), headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('markAsRead error: $e');
      return false;
    }
  }

  // PUT /api/notifications/read-all
  Future<bool> markAllAsRead() async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.notificationsReadAll}';
    try {
      final response = await _client
          .put(Uri.parse(url), headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('markAllAsRead error: $e');
      return false;
    }
  }

  // DELETE /api/notifications/{notification_id}
  Future<bool> deleteNotification(int notificationId) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.notificationById(notificationId)}';
    try {
      final response = await _client
          .delete(Uri.parse(url), headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('deleteNotification error: $e');
      return false;
    }
  }

  // GET /api/notifications/preferences
  Future<NotificationPreferences?> getPreferences() async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.notificationPreferences}';
    try {
      final response = await _client
          .get(Uri.parse(url), headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NotificationPreferences.fromJson(data);
      }
    } catch (e) {
      debugPrint('getPreferences error: $e');
    }
    return null;
  }

  // PUT /api/notifications/preferences
  Future<NotificationPreferences?> updatePreferences(NotificationPreferences prefs) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.notificationPreferences}';
    try {
      final response = await _client
          .put(
            Uri.parse(url),
            headers: _headers,
            body: jsonEncode(prefs.toJson()),
          )
          .timeout(ApiConstants.requestTimeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NotificationPreferences.fromJson(data);
      }
    } catch (e) {
      debugPrint('updatePreferences error: $e');
    }
    return null;
  }

  // POST /api/notifications/device-token
  Future<bool> registerDeviceToken(String token, String platform) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.notificationDeviceToken}';
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: _headers,
            body: jsonEncode({'device_token': token, 'platform': platform}),
          )
          .timeout(ApiConstants.requestTimeout);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('registerDeviceToken error: $e');
      return false;
    }
  }
}
