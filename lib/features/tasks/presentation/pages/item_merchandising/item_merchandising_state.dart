part of 'item_merchandising_cubit.dart';

class ItemMerchandisingState {
  final bool isLoading;
  final bool isFetching;
  final bool activeSearch;
  final int currentPage;
  final double stockQty;
  final List<Merchandise>? merchindises;
  final List<SalesPersonScheduleMerchandise> spsms;

  const ItemMerchandisingState({
    this.isLoading = false,
    this.currentPage = 1,
    this.stockQty = 0,
    this.merchindises,
    this.spsms = const [],
    this.activeSearch = false,
    this.isFetching = false,
  });

  ItemMerchandisingState copyWith({
    List<Merchandise>? merchindises,
    int? currentPage,
    bool? isFetching,
    bool? isLoading,
    double? stockQty,
    bool? activeSearch,
    List<SalesPersonScheduleMerchandise>? spsms,
  }) {
    return ItemMerchandisingState(
      isLoading: isLoading ?? this.isLoading,
      merchindises: merchindises ?? this.merchindises,
      currentPage: currentPage ?? this.currentPage,
      isFetching: isFetching ?? this.isFetching,
      stockQty: stockQty ?? this.stockQty,
      activeSearch: activeSearch ?? this.activeSearch,
      spsms: spsms ?? this.spsms,
    );
  }
}
