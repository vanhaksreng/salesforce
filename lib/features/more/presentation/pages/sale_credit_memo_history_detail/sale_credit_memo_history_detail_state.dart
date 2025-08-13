part of 'sale_credit_memo_history_detail_cubit.dart';

class SaleCreditMemoHistoryDetailState {
  final bool isLoading;
  final String? error;
  final SaleDetail? saleDetail;

  const SaleCreditMemoHistoryDetailState({
    this.isLoading = false,
    this.error,
    this.saleDetail,
  });

  SaleCreditMemoHistoryDetailState copyWith({
    bool? isLoading,
    String? error,
    SaleDetail? saleDetail,
  }) {
    return SaleCreditMemoHistoryDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      saleDetail: saleDetail ?? this.saleDetail,
    );
  }
}
