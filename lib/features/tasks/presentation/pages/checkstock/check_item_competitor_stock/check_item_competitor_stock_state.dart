import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class CheckItemCompetitorStockState {
  final bool isLoading;
  final List<CompetitorItem> items;
  final List<CompetitorItemLedgerEntry> cile;
  final CompetitorItemLedgerEntry? detailCompetitorLedgerEntry;
  final bool isFetching;
  final int currentPage;

  const CheckItemCompetitorStockState({
    this.isLoading = false,
    this.items = const [],
    this.cile = const [],
    this.detailCompetitorLedgerEntry,
    this.isFetching = false,
    this.currentPage = 1,
  });

  CheckItemCompetitorStockState copyWith({
    bool? isLoading,
    List<CompetitorItem>? items,
    List<CompetitorItemLedgerEntry>? cile,
    CompetitorItemLedgerEntry? detailCompetitorLedgerEntry,
    bool? isFetching,
    int? currentPage,
  }) {
    return CheckItemCompetitorStockState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      cile: cile ?? this.cile,
      isFetching: isFetching ?? this.isFetching,
      currentPage: currentPage ?? this.currentPage,
      detailCompetitorLedgerEntry: detailCompetitorLedgerEntry ?? this.detailCompetitorLedgerEntry,
    );
  }
}
