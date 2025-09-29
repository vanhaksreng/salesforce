import 'package:salesforce/features/tasks/domain/entities/sale_person_gps_model.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';

class TeamScheduleHistoryState {
  final bool isLoading;
  final String? error;
  final List<SalespersonSchedule> teamScheduleSalePersons;
  final List<SalePersonGpsModel> downLines;
  final SalePersonGpsModel? downLine;

  const TeamScheduleHistoryState({
    this.isLoading = false,
    this.error,
    this.teamScheduleSalePersons = const [],
    this.downLines = const [],
    this.downLine,
  });

  TeamScheduleHistoryState copyWith({
    bool? isLoading,
    String? error,
    List<SalespersonSchedule>? teamScheduleSalePersons,
    List<SalePersonGpsModel>? downLines,
    SalePersonGpsModel? downLine,
  }) {
    return TeamScheduleHistoryState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      downLines: downLines ?? this.downLines,
      downLine: downLine ?? this.downLine,
      teamScheduleSalePersons:
          teamScheduleSalePersons ?? this.teamScheduleSalePersons,
    );
  }
}
