part of 'process_cubit.dart';

class ProcessState {
  final bool isLoading;
  final bool isFetching;
  final bool loadingUpdate;
  final bool isLoadingSubmit;
  final bool isRefreshing;
  final int cartCount;
  final SalespersonSchedule? schedule;
  final ItemUnitOfMeasure? itemUom;
  final ActionState actionState;

  final int countCheckStock;
  final int countSaleOrder;
  final int countSaleInvoice;
  final int countSaleCreditMemo;
  final int countCollection;
  final int countCompetitorPromotion;
  final int countMerchandising;
  final int countPosm;
  final int countItemPrizeRedeption;

  const ProcessState({
    this.isLoading = false,
    this.isFetching = false,
    this.isRefreshing = false,
    this.cartCount = 0,
    this.loadingUpdate = false,
    this.isLoadingSubmit = false,
    this.itemUom,
    this.schedule,
    this.countCheckStock = 0,
    this.countSaleOrder = 0,
    this.countSaleInvoice = 0,
    this.countSaleCreditMemo = 0,
    this.countCollection = 0,
    this.countCompetitorPromotion = 0,
    this.countMerchandising = 0,
    this.countPosm = 0,
    this.countItemPrizeRedeption = 0,
    this.actionState = ActionState.init,
  });

  ProcessState copyWith({
    bool? isLoading,
    bool? isLoadingSubmit,
    bool? isRefreshing,
    String? error,
    bool? isFetching,
    int? cartCount,
    bool? loadingUpdate,
    ItemUnitOfMeasure? itemUom,
    SalespersonSchedule? schedule,
    int? countCheckStock,
    int? countSaleOrder,
    int? countSaleInvoice,
    int? countSaleCreditMemo,
    int? countCollection,
    int? countCompetitorPromotion,
    int? countMerchandising,
    int? countPosm,
    int? countItemPrizeRedeption,
    ActionState? actionState,
  }) {
    return ProcessState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingSubmit: isLoadingSubmit ?? this.isLoadingSubmit,
      cartCount: cartCount ?? this.cartCount,
      itemUom: itemUom ?? this.itemUom,
      isFetching: isFetching ?? this.isFetching,
      loadingUpdate: loadingUpdate ?? this.loadingUpdate,
      countCheckStock: countCheckStock ?? this.countCheckStock,
      countSaleOrder: countSaleOrder ?? this.countSaleOrder,
      countSaleInvoice: countSaleInvoice ?? this.countSaleInvoice,
      countSaleCreditMemo: countSaleCreditMemo ?? this.countSaleCreditMemo,
      countCollection: countCollection ?? this.countCollection,
      countCompetitorPromotion:
          countCompetitorPromotion ?? this.countCompetitorPromotion,
      countMerchandising: countMerchandising ?? this.countMerchandising,
      countPosm: countPosm ?? this.countPosm,
      countItemPrizeRedeption:
          countItemPrizeRedeption ?? this.countItemPrizeRedeption,
      actionState: actionState ?? this.actionState,
    );
  }
}
