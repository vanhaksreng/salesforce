import 'package:salesforce/features/report/domain/entities/so_outstanding_report_model.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class SoOutstandingReportState {
  final bool isLoading;
  final String? error;
  final DateTime? startDate;
  final DateTime? toDate;
  final bool? isFilter;
  final bool? isClick;
  final List<SoOutstandingReportModel>? records;
  final List<Salesperson>? recordSalespersons;
  final Salesperson? salesperson;
  final String? isSelectedSalesperson;
  final String? selectedStatus;
  final String? selectedDate;
  final bool isFetching;
  final int currentPage;
  final int lastPage;

  SoOutstandingReportState({
    this.isLoading = false,
    this.error,
    this.startDate,
    this.toDate,
    this.isFilter,
    this.isClick = false,
    this.records,
    this.recordSalespersons,
    this.salesperson,
    this.isSelectedSalesperson,
    this.selectedStatus,
    this.selectedDate,
    this.isFetching = false,
    this.currentPage = 1,
    this.lastPage = 1,
  });

  SoOutstandingReportState copyWith({
    bool? isLoading,
    String? error,
    DateTime? startDate,
    DateTime? toDate,
    bool? isFilter,
    bool? isClick,
    List<SoOutstandingReportModel>? records,
    List<Salesperson>? recordSalespersons,
    Salesperson? salesperson,
    String? isSelectedSalesperson,
    String? selectedStatus,
    String? selectedDate,
    bool? isFetching,
    int? currentPage,
    int? lastPage,
  }) {
    return SoOutstandingReportState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      startDate: startDate ?? this.startDate,
      toDate: toDate ?? this.toDate,
      isFilter: isFilter ?? this.isFilter,
      isClick: isClick ?? this.isClick,
      records: records ?? this.records,
      recordSalespersons: recordSalespersons ?? this.recordSalespersons,
      salesperson: salesperson ?? this.salesperson,
      isSelectedSalesperson:
          isSelectedSalesperson ?? this.isSelectedSalesperson,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedDate: selectedDate ?? this.selectedDate,
      isFetching: isFetching ?? this.isFetching,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
    );
  }
}
