import 'package:salesforce/features/report/domain/entities/stock_request_report_model.dart';

class StockRequestReportState {
  final bool isLoading;
  final String? error;
  final DateTime? startDate;
  final DateTime? toDate;
  final bool? isFilter;
  final List<StockRequestReportModel>? records;

  StockRequestReportState({
    this.isLoading = false,
    this.error,
    this.startDate,
    this.toDate,
    this.isFilter,
    this.records,
  });

  StockRequestReportState copyWith({
    bool? isLoading,
    String? error,
    DateTime? startDate,
    DateTime? toDate,
    bool? isFilter,
    List<StockRequestReportModel>? records,
  }) {
    return StockRequestReportState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      startDate: startDate ?? this.startDate,
      toDate: toDate ?? this.toDate,
      isFilter: isFilter ?? this.isFilter,
      records: records ?? this.records,
    );
  }
}
