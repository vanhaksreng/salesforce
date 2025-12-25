import 'package:salesforce/core/data/datasources/realm/base_realm_data_source.dart';
import 'package:salesforce/features/stock/domain/entities/transfer_line.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';

abstract class RealmStockDataSource extends BaseRealmDataSource {
  Future<List<ItemGroup>> getItemsGroups({int page = 1, Map<String, dynamic>? param});

  Future<List<ItemStockRequestWorkSheet>> getItemRequestWorksheets({Map<String, dynamic>? data});

  Future<ItemStockRequestWorkSheet?> getItemRequestWorksheet({Map<String, dynamic>? data});

  Future<void> storeStockRequest(
    ItemStockRequestWorkSheet record, {
    required double quantity,
    required String uomCode,
    required double qtyPerUnit,
  });

  Future<void> deleteStockRequest(ItemStockRequestWorkSheet record);

  Future<List<ItemStockRequestWorkSheet>> updateStockRequest(
    List<ItemStockRequestWorkSheet> records, {
    required String status,
    required String backendStatus,
    List<TransferLine> lines = const [],
    bool isFirstTime = false,
  });

  Future<ItemStockRequestWorkSheet> onChangeReceiveQty({
    required double quantityToReceive,
    required ItemStockRequestWorkSheet record,
  });
}
