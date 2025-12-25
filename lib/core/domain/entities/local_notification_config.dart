import 'package:salesforce/core/domain/entities/notification_entity.dart';

class LocalNotificationConfig {
  final String channelId;
  final String channelName;
  final String channelDescription;
  final NotificationPriority priority;
  final bool enableVibration;
  final bool enableSound;
  final String? soundFile;
  final String? icon;

  LocalNotificationConfig({
    required this.channelId,
    required this.channelName,
    required this.channelDescription,
    this.priority = NotificationPriority.normal,
    this.enableVibration = true,
    this.enableSound = true,
    this.soundFile,
    this.icon,
  });
}
