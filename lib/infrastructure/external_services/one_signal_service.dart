// // infrastructure/external_services/one_signal_service.dart
// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:salesforce/core/domain/entities/notification_entity.dart';
// import 'package:salesforce/core/domain/entities/one_signal_config.dart';
// import 'package:salesforce/core/domain/entities/push_subscription.dart';

// class OneSignalService {
//   static OneSignalService? _instance;
//   static OneSignalService get instance => _instance ??= OneSignalService._();
//   OneSignalService._();

//   final StreamController<NotificationEntity> _notificationController = StreamController<NotificationEntity>.broadcast();

//   final StreamController<NotificationEntity> _notificationOpenedController =
//       StreamController<NotificationEntity>.broadcast();

//   Stream<NotificationEntity> get notificationReceivedStream => _notificationController.stream;
//   Stream<NotificationEntity> get notificationOpenedStream => _notificationOpenedController.stream;

//   Future<void> initialize(OneSignalConfig config) async {
//     try {
//       // Initialize OneSignal
//       OneSignal.initialize(config.appId);

//       // Request notification permission
//       OneSignal.Notifications.requestPermission(true);

//       // Set up listeners
//       OneSignal.Notifications.addForegroundWillDisplayListener(_onForegroundWillDisplay);
//       OneSignal.Notifications.addClickListener(_onNotificationClicked);
//       OneSignal.InAppMessages.addWillDisplayListener(_onInAppMessageWillDisplay);
//       OneSignal.InAppMessages.addClickListener(_onInAppMessageClicked);
//       OneSignal.User.addObserver(_onUserStateChanged);

//       // Configure settings
//       if (config.enableInAppAlerts) {
//         OneSignal.InAppMessages.paused(false);
//       }

//       if (config.requiresUserPrivacyConsent) {
//         OneSignal.consentRequired(true);
//       }

//       // Set custom tags if provided
//       if (config.customTags != null) {
//         OneSignal.User.addTags(config.customTags!);
//       }
//     } catch (e) {
//       throw OneSignalException('Failed to initialize OneSignal: $e');
//     }
//   }

//   Future<bool> requestPermissions() async {
//     try {
//       final permission = await OneSignal.Notifications.requestPermission(true);
//       return permission;
//     } catch (e) {
//       debugPrint('OneSignal permission error: $e');
//       return false;
//     }
//   }

//   Future<void> setUserId(String userId) async {
//     OneSignal.login(userId);
//   }

//   Future<void> removeUserId() async {
//     OneSignal.logout();
//   }

//   Future<void> sendTag(String key, String value) async {
//     // OneSignal.User.addTag(key, value);
//   }

//   Future<void> sendTags(Map<String, String> tags) async {
//     OneSignal.User.addTags(tags);
//   }

//   Future<void> deleteTag(String key) async {
//     OneSignal.User.removeTag(key);
//   }

//   Future<void> deleteTags(List<String> keys) async {
//     OneSignal.User.removeTags(keys);
//   }

//   Future<PushSubscription> getSubscriptionState() async {
//     final user = OneSignal.User;
//     final pushSubscription = user.pushSubscription;

//     return PushSubscription(
//       userId: user.onesignalId,
//       pushToken: pushSubscription.token,
//       playerId: pushSubscription.id,
//       isSubscribed: pushSubscription.optedIn,
//     );
//   }

//   Future<void> setSubscription(bool enable) async {
//     if (enable) {
//       OneSignal.User.pushSubscription.optIn();
//     } else {
//       OneSignal.User.pushSubscription.optOut();
//     }
//   }

//   Future<void> promptForPushNotifications() async {
//     OneSignal.Notifications.requestPermission(true);
//   }

//   Future<void> sendNotificationToUser(String userId, NotificationEntity notification) async {
//     // This would typically be done through OneSignal REST API
//     // Implementation depends on your backend service
//     throw UnimplementedError('Server-side implementation required');
//   }

//   Future<void> sendNotificationToSegment(String segment, NotificationEntity notification) async {
//     // This would typically be done through OneSignal REST API
//     // Implementation depends on your backend service
//     throw UnimplementedError('Server-side implementation required');
//   }

//   void _onForegroundWillDisplay(OSNotificationWillDisplayEvent event) {
//     final notification = _convertOSNotificationToEntity(event.notification);
//     _notificationController.add(notification);

//     // Display the notification
//     event.notification.display();
//   }

//   void _onNotificationClicked(OSNotificationClickEvent event) {
//     final notification = _convertOSNotificationToEntity(event.notification);
//     _notificationOpenedController.add(notification);
//   }

//   void _onInAppMessageWillDisplay(OSInAppMessageWillDisplayEvent event) {
//     // Handle in-app message display
//     print('In-App Message Will Display: ${event.message.messageId}');
//   }

//   void _onInAppMessageClicked(OSInAppMessageClickEvent event) {
//     // Handle in-app message click
//     print('In-App Message Clicked: ${event.result.actionId}');
//   }

//   void _onUserStateChanged(OSUserStateChangedState state) {
//     // Handle user state changes (subscription, tags, etc.)
//     print('User State Changed');
//   }

//   NotificationEntity _convertOSNotificationToEntity(OSNotification osNotification) {
//     final additionalData = osNotification.additionalData ?? {};

//     return NotificationEntity(
//       id: osNotification.notificationId,
//       title: osNotification.title ?? '',
//       message: osNotification.body ?? '',
//       timestamp: DateTime.now(),
//       type: additionalData['type']?.toString() ?? 'general',
//       payload: additionalData,
//       source: NotificationSource.oneSignal,
//       imageUrl: osNotification.bigPicture ?? osNotification.smallIcon,
//       actionUrl: osNotification.launchURL,
//       actions: osNotification.actionButtons
//           ?.map((button) => NotificationAction(
//                 id: button.id,
//                 title: button.text,
//                 icon: button.icon,
//               ))
//           .toList(),
//     );
//   }

//   void dispose() {
//     _notificationController.close();
//     _notificationOpenedController.close();
//   }
// }

// class OneSignalException implements Exception {
//   final String message;
//   OneSignalException(this.message);
// }
