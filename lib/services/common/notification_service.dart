import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yemis/utils/constants/api_constants.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'high_importance_channel';
  static const String channelName = 'High Importance Notifications';
  static const String channelDescription =
      'This channel is used for important notifications.';

  Future<void> initialize() async {
    // 1. Request Permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true,
    );

    // 2. Set Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Local Notifications Initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          ),
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) {
          print('Notification clicked: ${response.payload}');
        }
      },
    );

    // 4. Create Android Notification Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // 5. iOS Foreground Notification Options
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 6. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      final accentColor = _colorFromHex(message.data['accent_color']);

      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          message.data['title'] ?? notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android?.smallIcon ?? '@mipmap/ic_launcher',
              color: accentColor,
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker',
              playSound: true,
              enableVibration: true,
              visibility: NotificationVisibility.public,
              fullScreenIntent:
                  false, // Set to true for even more intrusive alerts
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // 7. Handle Background/Terminated Message Clicks
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('A new onMessageOpenedApp event was published!');
      }
    });

    // Token registration is handled after the session is loaded. Do not block
    // app startup when Firebase Messaging is temporarily unavailable.
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          visibility: NotificationVisibility.public,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<String?> getToken({
    int retries = 1,
    Duration timeout = ApiConstants.notificationTokenTimeout,
  }) async {
    Duration delay = const Duration(seconds: 2);

    for (int i = 0; i < retries; i++) {
      try {
        if (kDebugMode) {
          print('Fetching FCM token (Attempt ${i + 1}/$retries)...');
        }
        final token = await _fcm.getToken().timeout(timeout);
        if (token != null) {
          if (kDebugMode) {
            print('Successfully fetched FCM token.');
          }
          return token;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Attempt ${i + 1} failed to get FCM token: $e');
        }
        if (i == retries - 1) {
          return null;
        }
        await Future.delayed(delay);
        delay = delay * 2; // Exponential backoff
      }
    }
    return null;
  }

  Color? _colorFromHex(dynamic value) {
    if (value == null) return null;
    final normalized = value.toString().trim().replaceFirst('#', '');
    if (normalized.length != 6 && normalized.length != 8) return null;
    final colorValue = int.tryParse(normalized, radix: 16);
    if (colorValue == null) return null;
    return Color(normalized.length == 6 ? 0xFF000000 | colorValue : colorValue);
  }
}
