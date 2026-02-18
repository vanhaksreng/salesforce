part of 'sale_order_history_detail_cubit.dart';

class SaleOrderHistoryDetailState {
  final bool isLoading;
  final String? error;
  final SaleDetail? record;
  final CompanyInformation? comPanyInfo;

  const SaleOrderHistoryDetailState({
    this.isLoading = false,
    this.error,
    this.record,
    this.comPanyInfo,
  });

  SaleOrderHistoryDetailState copyWith({
    bool? isLoading,

    String? error,
    SaleDetail? record,
    CompanyInformation? comPanyInfo,
  }) {
    return SaleOrderHistoryDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      record: record ?? this.record,
      comPanyInfo: comPanyInfo ?? this.comPanyInfo,
    );
  }
}
