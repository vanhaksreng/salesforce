class NotificationEntity {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String type;
  final Map<String, dynamic>? payload;
  final bool isLocal;
  final NotificationPriority priority;

  NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.payload,
    this.isLocal = false,
    this.priority = NotificationPriority.normal,
  });
}

enum NotificationPriority { low, normal, high, urgent }
