part of 'item_posm_cubit.dart';

class ItemPosmState {
  final bool isLoading;
  final bool isFetching;
  final bool activeSearch;
  final int currentPage;

  final List<PointOfSalesMaterial> posms;
  final List<SalesPersonScheduleMerchandise> spsms;

  const ItemPosmState({
    this.isLoading = false,
    this.currentPage = 1,
    this.posms = const [],
    this.activeSearch = false,
    this.isFetching = false,
    this.spsms = const [],
  });

  ItemPosmState copyWith({
    List<PointOfSalesMaterial>? posms,
    int? currentPage,
    bool? isFetching,
    bool? isLoading,
    bool? activeSearch,
    double? stockQty,
    List<SalesPersonScheduleMerchandise>? spsms,
  }) {
    return ItemPosmState(
      isLoading: isLoading ?? this.isLoading,
      posms: posms ?? this.posms,
      currentPage: currentPage ?? this.currentPage,
      isFetching: isFetching ?? this.isFetching,
      activeSearch: activeSearch ?? this.activeSearch,
      spsms: spsms ?? this.spsms,
    );
  }
}
