import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:salesforce/env.dart';

class OneSignalNotificationService {
  static const String _oneSignalAppId = kOneSignalKey;
  static const String _channelId = 'Tradeb2b_channel_id';
  static const String _channelName = 'Tradeb2b_channel_name';
  static const String _notificationIcon = '@mipmap/ic_launcher';

  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _initSettings = InitializationSettings(
    android: AndroidInitializationSettings(_notificationIcon),
    iOS: DarwinInitializationSettings(),
  );

  static void initialize() {
    _initializeOneSignal();
    _setupNotificationListeners();
  }

  static void _initializeOneSignal() async {
    OneSignal.initialize(_oneSignalAppId);

    OneSignal.Notifications.requestPermission(true);

    OneSignal.LiveActivities.setupDefault();

    _localNotifications.initialize(_initSettings);
  }

  static void _setupNotificationListeners() {
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.preventDefault();
      event.notification.display();
    });
    OneSignal.Notifications.addForegroundWillDisplayListener(_handleForegroundNotification);
  }

  static Future<void> _handleForegroundNotification(event) async {
    try {
      final notification = event.notification;
      final data = notification.additionalData;

      final String imagePath = data != null ? await _downloadAndSaveImage(data['imageUrl'] ?? '') : '';

      await _showLocalNotification(notification: notification, imagePath: imagePath);

      event.preventDefault();
    } catch (e) {
      //
    }
  }

  static Future<void> _showLocalNotification({required OSNotification notification, required String imagePath}) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: _notificationIcon,
      largeIcon: imagePath.isNotEmpty ? FilePathAndroidBitmap(imagePath) : null,
    );

    await _localNotifications.show(
      notification.notificationId.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(android: androidDetails),
    );
  }

  static Future<String> _downloadAndSaveImage(String url) async {
    if (url.isEmpty) return '';

    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) return '';

      final String filePath = '${directory.path}/notification_image.png';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) return '';

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } catch (e) {
      return '';
    }
  }
}
