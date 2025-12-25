import 'package:salesforce/features/report/domain/entities/daily_sale_sumary_report_model.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class DailySaleSummaryReportState {
  final bool isLoading;
  final String? error;
  final DateTime? startDate;
  final DateTime? toDate;
  final bool? isFilter;
  final bool? isClick;
  final List<DailySaleSumaryReportModel>? records;
  final String? isSelectedSalesperson;
  final Salesperson? salesperson;
  final List<Salesperson>? recordSalespersons;

  const DailySaleSummaryReportState({
    this.isLoading = false,
    this.error,
    this.startDate,
    this.toDate,
    this.isFilter,
    this.isClick,
    this.records,
    this.isSelectedSalesperson,
    this.salesperson,
    this.recordSalespersons,
  });

  DailySaleSummaryReportState copyWith({
    bool? isLoading,
    String? error,
    DateTime? startDate,
    DateTime? toDate,
    bool? isFilter,
    bool? isClick,
    List<DailySaleSumaryReportModel>? records,
    String? isSelectedSalesperson,
    Salesperson? salesperson,
    List<Salesperson>? recordSalespersons,
  }) {
    return DailySaleSummaryReportState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      startDate: startDate ?? this.startDate,
      toDate: toDate ?? this.toDate,
      isFilter: isFilter ?? this.isFilter,
      isClick: isClick ?? this.isClick,
      records: records ?? this.records,
      isSelectedSalesperson: isSelectedSalesperson ?? this.isSelectedSalesperson,
      salesperson: salesperson ?? this.salesperson,
      recordSalespersons: recordSalespersons ?? this.recordSalespersons,
    );
  }
}
