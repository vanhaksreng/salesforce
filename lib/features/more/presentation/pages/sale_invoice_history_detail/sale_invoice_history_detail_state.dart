part of 'sale_invoice_history_detail_cubit.dart';

class SaleInvoiceHistoryDetailState {
  final bool isLoading;
  final String? error;
  final SaleDetail? record;

  const SaleInvoiceHistoryDetailState({
    this.isLoading = false,
    this.error,
    this.record,
  });

  SaleInvoiceHistoryDetailState copyWith({
    bool? isLoading,
    String? error,
    SaleDetail? record,
  }) {
    return SaleInvoiceHistoryDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      record: record ?? this.record,
    );
  }
}
