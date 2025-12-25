part of 'main_page_stock_cubit.dart';

class MainPageStockState {
  final bool isLoading;
  final bool loadingUpdate;
  final List<Item> items;
  final List<ItemStockRequestWorkSheet> itemWorkSheet;
  final String uomCode;
  final bool isFetching;
  final int currentPage;

  const MainPageStockState({
    this.isLoading = false,
    this.loadingUpdate = false,
    this.uomCode = "",
    this.items = const [],
    this.itemWorkSheet = const [],
    this.isFetching = false,
    this.currentPage = 1,
  });

  MainPageStockState copyWith({
    bool? isLoading,
    bool? loadingUpdate,
    List<Item>? items,
    List<ItemStockRequestWorkSheet>? itemWorkSheet,
    String? uomCode,
    bool? isFetching,
    int? currentPage,
  }) {
    return MainPageStockState(
      isLoading: isLoading ?? this.isLoading,
      itemWorkSheet: itemWorkSheet ?? this.itemWorkSheet,
      items: items ?? this.items,
      uomCode: uomCode ?? this.uomCode,
      loadingUpdate: loadingUpdate ?? this.loadingUpdate,
      isFetching: isFetching ?? this.isFetching,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
