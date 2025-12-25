import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';

class StockState {
  final bool isLoading;
  final bool isFetching;
  final bool loadingUpdate;
  final bool isLoadingSubmit;
  final String? error;
  final String? valueInput;
  final String? documentNo;
  final List<Item>? items;
  final List<ItemStockRequestWorkSheet>? itemWorkSheet;
  final String countQTY;
  final String uomCode;
  final List<ItemUnitOfMeasure>? itemUom;

  const StockState({
    this.isLoading = false,
    this.isFetching = false,
    this.loadingUpdate = false,
    this.isLoadingSubmit = false,
    this.error,
    this.itemWorkSheet,
    this.countQTY = "0",
    this.documentNo = "0",
    this.valueInput = "",
    this.uomCode = "",
    this.items,
    this.itemUom,
  });

  StockState copyWith({
    bool? isLoading,
    bool? isLoadingSubmit,
    String? error,
    bool? isFetching,
    bool? loadingUpdate,
    String? valueInput,
    String? documentNo,
    List<Item>? items,
    List<ItemStockRequestWorkSheet>? itemWorkSheet,
    String? countQTY,
    String? uomCode,
    List<ItemUnitOfMeasure>? itemUom,
  }) {
    return StockState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingSubmit: isLoadingSubmit ?? this.isLoadingSubmit,
      error: error ?? this.error,
      itemWorkSheet: itemWorkSheet ?? this.itemWorkSheet,
      items: items ?? this.items,
      countQTY: countQTY ?? this.countQTY,
      valueInput: valueInput ?? this.valueInput,
      isFetching: isFetching ?? this.isFetching,
      loadingUpdate: loadingUpdate ?? this.loadingUpdate,
      itemUom: itemUom ?? this.itemUom,
      uomCode: uomCode ?? this.uomCode,
      documentNo: documentNo ?? this.documentNo,
    );
  }
}
