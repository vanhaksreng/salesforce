import 'package:salesforce/realm/scheme/tasks_schemas.dart';

class ScheduleHistoryState {
  final bool isLoading;
  final List<SalespersonSchedule>? schedules;

  const ScheduleHistoryState({this.isLoading = false, this.schedules});

  ScheduleHistoryState copyWith({bool? isLoading, List<SalespersonSchedule>? schedules}) {
    return ScheduleHistoryState(isLoading: isLoading ?? this.isLoading, schedules: schedules ?? this.schedules);
  }
}
