import 'package:salesforce/realm/scheme/sales_schemas.dart';

class SaleOrderHistoryState {
  final bool isLoading;
  final String? error;
  final List<SalesHeader> records;
  final List<SalesLine> saleLines;
  final DateTime? startDate;
  final DateTime? toDate;
  final String? selectedStatus;
  final String? selectedDate;
  final bool? isFilter;
  final int currentPage;
  final int lastPage;
  final bool isFetching;
  final String? htmlContent;
  final Map<String, double> headerTotals;
  final bool canSaleWithSchedult;
  final bool hasPendingUpload;

  const SaleOrderHistoryState({
    this.isLoading = false,
    this.error,
    this.records = const [],
    this.saleLines = const [],
    this.startDate,
    this.toDate,
    this.currentPage = 1,
    this.lastPage = 1,
    this.selectedStatus,
    this.selectedDate,
    this.isFilter,
    this.isFetching = false,
    this.htmlContent,
    this.headerTotals = const {},
    this.canSaleWithSchedult = false,
    this.hasPendingUpload = false,
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
    List<SalesLine>? saleLines,
    int? lastPage,
    bool? isFetching,
    String? htmlContent,
    Map<String, double>? headerTotals,
    bool? canSaleWithSchedult,
    bool? hasPendingUpload,
  }) {
    return SaleOrderHistoryState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      records: records ?? this.records,
      saleLines: saleLines ?? this.saleLines,
      startDate: startDate ?? this.startDate,
      toDate: toDate ?? this.toDate,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      isFilter: isFilter ?? this.isFilter,
      selectedDate: selectedDate ?? this.selectedDate,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isFetching: isFetching ?? this.isFetching,
      htmlContent: htmlContent ?? this.htmlContent,
      headerTotals: headerTotals ?? this.headerTotals,
      canSaleWithSchedult: canSaleWithSchedult ?? this.canSaleWithSchedult,
      hasPendingUpload: hasPendingUpload ?? this.hasPendingUpload,
    );
  }
}
