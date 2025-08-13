import 'package:salesforce/realm/scheme/sales_schemas.dart';

class SaleOrderHistoryState {
  final bool isLoading;
  final String? error;
  final List<SalesHeader> records;
  final DateTime? startDate;
  final DateTime? toDate;
  final String? selectedStatus;
  final String? selectedDate;
  final bool? isFilter;
  final int currentPage;
  final int lastPage;
  final bool isFetching;
  final String? htmlContent;

  const SaleOrderHistoryState({
    this.isLoading = false,
    this.error,
    this.records = const [],
    this.startDate,
    this.toDate,
    this.currentPage = 1,
    this.lastPage = 1,
    this.selectedStatus,
    this.selectedDate,
    this.isFilter,
    this.isFetching = false,
    this.htmlContent,
  });

  SaleOrderHistoryState copyWith({
    bool? isLoading,
    String? error,
    List<SalesHeader>? records,
    DateTime? startDate,
    DateTime? toDate,
    String? selectedStatus,
    String? selectedDate,
    bool? isFilter,
    int? currentPage,
    int? lastPage,
    bool? isFetching,
    String? htmlContent,
  }) {
    return SaleOrderHistoryState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      records: records ?? this.records,
      startDate: startDate ?? this.startDate,
      toDate: toDate ?? this.toDate,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      isFilter: isFilter ?? this.isFilter,
      selectedDate: selectedDate ?? this.selectedDate,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isFetching: isFetching ?? this.isFetching,
      htmlContent: htmlContent ?? this.htmlContent,
    );
  }
}
