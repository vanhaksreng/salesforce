import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/tasks_main_state.dart';
import 'package:salesforce/injection_container.dart';

class TasksMainCubit extends Cubit<TasksMainState> with MessageMixin, AppMixin {
  TasksMainCubit() : super(const TasksMainState(isLoading: false));

  final _repos = getIt<TaskRepository>();

  void setRefreshChild() {
    emit(state.copyWith(refreshChild: !state.refreshChild));
  }

  Future<void> getUserSetup() async {
    final userSetupRes = await _repos.getUserSetup();
    userSetupRes.fold((l) => throw GeneralException(l.message), (user) => emit(state.copyWith(user: user)));
  }

  void setText(String text) {
    emit(state.copyWith(text: text));
  }

  void setActiveTap(int index) {
    emit(state.copyWith(activeTap: index));
  }

  Future<void> refreshSchedules() async {
    try {
      final response = await _repos.getSchedules(DateTime.now().toDateString(), requestApi: true);

      response.fold((failure) => throw GeneralException(failure.message), (items) {
        showSuccessMessage("Your schedule is up to date.");
        emit(state.copyWith(isLoading: false, refreshChild: !state.refreshChild));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
      emit(state.copyWith(isLoading: false));
    } catch (error) {
      showErrorMessage();
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> checkPendingOldSchedule() async {
    if (state.user == null) {
      throw GeneralException("User setup not found");
    }

    final response = await _repos.getLocalSchedules(
      param: {
        'status': '!= $kStatusCheckOut',
        'salesperson_code': state.user?.salespersonCode,
        'schedule_date': '!= ${DateTime.now().toDateString()}',
      },
    );

    response.fold((failure) => emit(state.copyWith(hasPendingOldSchedule: false)), (schedules) {
      emit(state.copyWith(hasPendingOldSchedule: schedules.isNotEmpty, oldSchedules: schedules));
    });
  }

  Future<void> moveOldScheduleToCurrentDate() async {
    await _repos.moveOldScheduleToCurrentDate(state.oldSchedules);
    setRefreshChild();
  }

  Future<void> checkAppVersion({Map<String, dynamic>? param}) async {
    try {
      final response = await _repos.checkAppVersion(param: param);

      response.fold(
        (l) => throw GeneralException(l.message),
        (appVersion) => emit(state.copyWith(appVersion: appVersion)),
      );
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (error) {
      showErrorMessage();
    }
  }
}
