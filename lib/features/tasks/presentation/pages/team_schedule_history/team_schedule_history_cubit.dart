import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/tasks/domain/entities/sale_person_gps_model.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/team_schedule_history/team_schedule_history_state.dart';
import 'package:salesforce/injection_container.dart';

class TeamScheduleHistoryCubit extends Cubit<TeamScheduleHistoryState>
    with MessageMixin {
  TeamScheduleHistoryCubit()
    : super(
        TeamScheduleHistoryState(isLoading: true, scheduleDate: DateTime.now()),
      );

  final _repos = getIt<TaskRepository>();

  Future<void> getTeamSchedules({
    Map<String, dynamic>? param,
    bool isLoadingSchedule = true,
  }) async {
    try {
      final response = await _repos.getTeamSchedules(param: param);
      emit(
        state.copyWith(isLoading: true, isLoadingSchedule: isLoadingSchedule),
      );
      response.fold(
        (failure) {
          print("================${failure.message}");
          emit(
            state.copyWith(
              isLoading: false,
              error: failure.message,
              isLoadingSchedule: false,
            ),
          );
        },
        (items) => emit(
          state.copyWith(
            teamScheduleSalePersons: items,
            isLoading: false,
            isLoadingSchedule: false,
          ),
        ),
      );
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (error) {
      emit(state.copyWith(isLoading: false, isLoadingSchedule: false));
      showErrorMessage();
    }
  }

  Future<void> getSalePersonDownline() async {
    final allOption = SalePersonGpsModel(
      avatar: "",
      code: "",
      name: 'All',
      phoneNo: '',
      latitude: '',
      longitude: '',
      trackingDate: '',
    );
    try {
      emit(state.copyWith(isLoading: true, isLoadingSchedule: true));

      final response = await _repos.getSalepersonGps();
      response.fold(
        (failure) {
          emit(
            state.copyWith(
              isLoading: false,
              isLoadingSchedule: false,
              error: failure.message,
            ),
          );
        },
        (items) => emit(
          state.copyWith(isLoading: false, downLines: [allOption, ...items]),
        ),
      );
    } catch (error) {
      showWarningMessage(error.toString());

      emit(state.copyWith(isLoading: false));
    }
  }

  void selectDownline(String? downLineCode) {
    emit(state.copyWith(isLoadingSchedule: true));
    emit(state.copyWith(downLineCode: downLineCode));
  }

  void selectDateTime(DateTime? scheduleDate) {
    emit(state.copyWith(isLoadingSchedule: true));
    emit(state.copyWith(scheduleDate: scheduleDate));
  }
}
