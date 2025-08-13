import 'package:salesforce/realm/scheme/sales_schemas.dart';

class SaleInvoiceHistoryState {
  final bool isLoading;
  final String? error;
  final List<SalesHeader> records;
  final DateTime? startDate;
  final DateTime? toDate;
  final String? selectedStatus;
  final bool? isFilter;
  final String? selectedDate;
  final bool isFetching;
  final int currentPage;
  final int lastPage;

  const SaleInvoiceHistoryState({
    this.isLoading = false,
    this.error,
    this.records = const [],
    this.startDate,
    this.toDate,
    this.selectedStatus,
    this.isFilter,
    this.selectedDate,
    this.isFetching = false,
    this.currentPage = 1,
    this.lastPage = 1,
  });

  SaleInvoiceHistoryState copyWith({
    bool? isLoading,
    String? error,
    List<SalesHeader>? records,
    DateTime? startDate,
    DateTime? toDate,
    String? selectedStatus,
    bool? isFilter,
    String? selectedDate,
    bool? isFetching,
    int? currentPage,
    int? lastPage,
  }) {
    return SaleInvoiceHistoryState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      records: records ?? this.records,
      startDate: startDate ?? this.startDate,
      toDate: toDate ?? this.toDate,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      isFilter: isFilter ?? this.isFilter,
      selectedDate: selectedDate ?? this.selectedDate,
      isFetching: isFetching ?? this.isFetching,
      lastPage: lastPage ?? this.lastPage,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
