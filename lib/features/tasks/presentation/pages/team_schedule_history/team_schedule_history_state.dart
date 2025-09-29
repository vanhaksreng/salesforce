import 'package:salesforce/features/tasks/domain/entities/sale_person_gps_model.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';

class TeamScheduleHistoryState {
  final bool isLoading;
  final bool isLoadingSchedule;
  final String? error;
  final List<SalespersonSchedule> teamScheduleSalePersons;
  final List<SalePersonGpsModel> downLines;
  final String downLineCode;
  final DateTime? scheduleDate;

  const TeamScheduleHistoryState({
    this.isLoading = false,
    this.isLoadingSchedule = false,
    this.error,
    this.teamScheduleSalePersons = const [],
    this.downLines = const [],
    this.downLineCode = "",
    this.scheduleDate,
  });

  TeamScheduleHistoryState copyWith({
    bool? isLoading,
    String? error,
    List<SalespersonSchedule>? teamScheduleSalePersons,
    List<SalePersonGpsModel>? downLines,
    String? downLineCode,
    bool? isLoadingSchedule,
    DateTime? scheduleDate,
  }) {
    return TeamScheduleHistoryState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      downLines: downLines ?? this.downLines,
      downLineCode: downLineCode ?? this.downLineCode,
      scheduleDate: scheduleDate ?? this.scheduleDate,
      isLoadingSchedule: isLoadingSchedule ?? this.isLoadingSchedule,
      teamScheduleSalePersons:
          teamScheduleSalePersons ?? this.teamScheduleSalePersons,
    );
  }
}
