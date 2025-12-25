import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class CheckItemStockState {
  final bool isLoading;
  final List<Item> items;
  final List<CustomerItemLedgerEntry> cile;
  final CustomerItemLedgerEntry? detailCustomerItemLedgerEntry;
  final bool isFetching;
  final int currentPage;

  const CheckItemStockState({
    this.isLoading = false,
    this.items = const [],
    this.cile = const [],
    this.detailCustomerItemLedgerEntry,
    this.isFetching = false,
    this.currentPage = 1,
  });

  CheckItemStockState copyWith({
    bool? isLoading,
    List<Item>? items,
    List<CustomerItemLedgerEntry>? cile,
    CustomerItemLedgerEntry? detailCustomerItemLedgerEntry,
    bool? isFetching,
    int? currentPage,
  }) {
    return CheckItemStockState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      detailCustomerItemLedgerEntry: detailCustomerItemLedgerEntry ?? this.detailCustomerItemLedgerEntry,
      cile: cile ?? this.cile,
      isFetching: isFetching ?? this.isFetching,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
