part of 'sale_order_history_detail_cubit.dart';

class SaleOrderHistoryDetailState {
  final bool isLoading;
  final String? error;
  final SaleDetail? record;

  const SaleOrderHistoryDetailState({
    this.isLoading = false,
    this.error,
    this.record,
  });

  SaleOrderHistoryDetailState copyWith({
    bool? isLoading,
    String? error,
    SaleDetail? record,
  }) {
    return SaleOrderHistoryDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      record: record ?? this.record,
    );
  }
}
