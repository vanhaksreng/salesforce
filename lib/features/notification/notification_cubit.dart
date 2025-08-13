import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/auth/domain/repositories/auth_repository.dart';
import 'package:salesforce/features/notification/notification_state.dart';
import 'package:salesforce/injection_container.dart';

class NotificationCubit extends Cubit<NotificationState> with MessageMixin {
  NotificationCubit() : super(const NotificationState(isLoading: true));

  final _notificationRepos = getIt<AuthRepository>();

  Future<void> getNotification() async {
    try {
      final response = await _notificationRepos.getNotification();
      return response.fold((l) => throw GeneralException(l.message), (items) {
        emit(
          state.copyWith(
            isLoading: false,
            notifications: items.notifications,
            countnotifications: items.countNotification,
          ),
        );
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }
}
