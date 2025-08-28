import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';

class ItemsState {
  final bool isLoading;
  final bool isFetching;
  final bool loadingUpdate;
  final bool isLoadingSubmit;
  final int cartCount;
  final int currentPage;
  final List<Item> items;
  final List<PosSalesLine> saleLines;
  final String? lastSelectedCode;
  final bool? activeFilter;

  const ItemsState({
    this.isLoading = false,
    this.isFetching = false,
    this.cartCount = 0,
    this.loadingUpdate = false,
    this.isLoadingSubmit = false,
    this.currentPage = 1,
    this.lastSelectedCode,
    this.items = const [],
    this.saleLines = const [],
    this.activeFilter,
  });

  ItemsState copyWith({
    bool? isLoading,
    bool? isLoadingSubmit,
    String? error,
    bool? isFetching,
    int? cartCount,
    int? currentPage,
    String? lastSelectedCode,
    bool? loadingUpdate,
    List<Item>? items,
    List<PosSalesLine>? saleLines,
    bool? activeFilter,
  }) {
    return ItemsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingSubmit: isLoadingSubmit ?? this.isLoadingSubmit,
      items: items ?? this.items,
      lastSelectedCode: lastSelectedCode ?? lastSelectedCode,
      cartCount: cartCount ?? this.cartCount,
      currentPage: currentPage ?? this.currentPage,
      activeFilter: activeFilter ?? activeFilter,
      isFetching: isFetching ?? this.isFetching,
      loadingUpdate: loadingUpdate ?? this.loadingUpdate,
      saleLines: saleLines ?? this.saleLines,
    );
  }
}
