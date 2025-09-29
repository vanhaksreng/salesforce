import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/tasks/domain/entities/sale_person_gps_model.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/team_schedule_history/team_schedule_history_state.dart';
import 'package:salesforce/injection_container.dart';

class TeamScheduleHistoryCubit extends Cubit<TeamScheduleHistoryState>
    with MessageMixin {
  TeamScheduleHistoryCubit() : super(TeamScheduleHistoryState(isLoading: true));

  final _repos = getIt<TaskRepository>();

  Future<void> getTeamSchedules(
    String visiteDate, {
    Map<String, dynamic>? param,
  }) async {
    try {
      final response = await _repos.getTeamSchedules(visiteDate, param: param);

      response.fold(
        (failure) => throw GeneralException(failure.message),
        (items) => emit(
          state.copyWith(teamScheduleSalePersons: items, isLoading: false),
        ),
      );
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (error) {
      emit(state.copyWith(isLoading: false));
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
      emit(state.copyWith(isLoading: true));

      final response = await _repos.getSalepersonGps();
      response.fold(
        (failure) => throw Exception(failure.message),
        (items) => emit(
          state.copyWith(isLoading: false, downLines: [allOption, ...items]),
        ),
      );
    } catch (error) {
      showWarningMessage(error.toString());

      emit(state.copyWith(isLoading: false));
    }
  }

  void selectDownline(SalePersonGpsModel downLine) {
    emit(state.copyWith(downLine: downLine));
  }
}
