import 'package:salesforce/features/auth/domain/entities/notification_model.dart';

class NotificationState {
  final bool isLoading;
  final String? error;
  final List<NotificationModel> notifications;
  final int countnotifications;

  const NotificationState({
    this.isLoading = false,
    this.error,
    this.notifications = const [],
    this.countnotifications = 0,
  });

  NotificationState copyWith({
    bool? isLoading,
    String? error,
    List<NotificationModel>? notifications,
    int? countnotifications,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      notifications: notifications ?? this.notifications,
      countnotifications: countnotifications ?? this.countnotifications,
    );
  }
}
