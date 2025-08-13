import 'package:salesforce/realm/scheme/sales_schemas.dart';

class SaleCreditMemoHistoryState {
  final bool isLoading;
  final String? error;
  final List<SalesHeader> records;
  final DateTime? startDate;
  final DateTime? toDate;
  final String? selectedStatus;
  final bool? isFilter;
  final int currentPage;
  final int lastPage;
  final bool isFetching;
  final String? selectedDate;

  const SaleCreditMemoHistoryState({
    this.isLoading = false,
    this.error,
    this.records = const [],
    this.startDate,
    this.toDate,
    this.selectedStatus,
    this.isFilter,
    this.currentPage = 1,
    this.lastPage = 1,
    this.isFetching = false,
    this.selectedDate,
  });
  SaleCreditMemoHistoryState copyWith({
    bool? isLoading,
    String? error,
    List<SalesHeader>? records,
    DateTime? startDate,
    DateTime? toDate,
    String? selectedStatus,
    bool? isFilter,
    int? currentPage,
    int? lastPage,
    bool? isFetching,
    String? selectedDate,
  }) {
    return SaleCreditMemoHistoryState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      records: records ?? this.records,
      startDate: startDate ?? this.startDate,
      toDate: toDate ?? this.toDate,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      isFilter: isFilter ?? this.isFilter,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isFetching: isFetching ?? this.isFetching,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}
