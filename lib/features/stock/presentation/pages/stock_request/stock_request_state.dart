import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';

class StockRequestState {
  final bool isLoading;
  final String documentNo;
  final String headerStatus;
  final List<ItemStockRequestWorkSheet> itemWorkSheet;

  const StockRequestState({
    this.isLoading = false,
    this.itemWorkSheet = const [],
    this.documentNo = "",
    this.headerStatus = kStatusOpen,
  });

  StockRequestState copyWith({
    bool? isLoading,
    List<ItemStockRequestWorkSheet>? itemWorkSheet,
    String? documentNo,
    String? headerStatus,
  }) {
    return StockRequestState(
      isLoading: isLoading ?? this.isLoading,
      itemWorkSheet: itemWorkSheet ?? this.itemWorkSheet,
      documentNo: documentNo ?? documentNo ?? this.documentNo,
      headerStatus: headerStatus ?? this.headerStatus,
    );
  }
}
