import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/schedule_history/schedule_history_state.dart';
import 'package:salesforce/injection_container.dart';

class ScheduleHistoryCubit extends Cubit<ScheduleHistoryState> {
  ScheduleHistoryCubit() : super(const ScheduleHistoryState(isLoading: true));

  final repos = getIt<TaskRepository>();

  Future<void> getSchedules(DateTime date, {bool isLoading = true}) async {
    try {
      emit(state.copyWith(isLoading: isLoading));
      final String visitDate = date.toDateString();

      final response = await repos.getSchedules(visitDate, requestApi: false);
      response.fold(
        (failure) => throw Exception(failure.message),
        (items) => emit(state.copyWith(isLoading: false, schedules: items)),
      );
    } catch (error) {
      Helpers.showMessage(msg: error.toString(), status: MessageStatus.errors);
      emit(state.copyWith(isLoading: false));
    }
  }
}
