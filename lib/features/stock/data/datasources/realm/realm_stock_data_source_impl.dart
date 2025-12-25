import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/data/datasources/realm/base_realm_data_source_impl.dart';
import 'package:salesforce/infrastructure/storage/i_local_storage.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/features/stock/data/datasources/realm/realm_stock_data_source.dart';
import 'package:salesforce/features/stock/domain/entities/transfer_line.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';

class RealmStockDataSourceImpl extends BaseRealmDataSourceImpl implements RealmStockDataSource {
  final ILocalStorage ils;
  RealmStockDataSourceImpl({required this.ils}) : super(ils: ils);

  @override
  Future<List<ItemGroup>> getItemsGroups({int page = 1, Map<String, dynamic>? param}) async {
    return await ils.getWithPagination<ItemGroup>(page: page, args: param);
  }

  @override
  Future<List<ItemStockRequestWorkSheet>> getItemRequestWorksheets({Map<String, dynamic>? data}) async {
    return await ils.getAll<ItemStockRequestWorkSheet>(args: data);
  }

  @override
  Future<ItemStockRequestWorkSheet?> getItemRequestWorksheet({Map<String, dynamic>? data}) async {
    return await ils.getFirst<ItemStockRequestWorkSheet>(args: data);
  }

  @override
  Future<void> storeStockRequest(
    ItemStockRequestWorkSheet record, {
    required double quantity,
    required String uomCode,
    required double qtyPerUnit,
  }) async {
    try {
      await ils.writeTransaction((realm) {
        record.quantity = quantity;
        record.quantityToShip = quantity;
        record.quantityToReceive = quantity;
        record.orgQuantity = quantity;
        record.unitOfMeasureCode = uomCode;
        record.qtyPerUnitOfMeasure = qtyPerUnit;
        record.quantityBase = quantity * qtyPerUnit;

        realm.add(record, update: true); //TODO

        return "success";
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteStockRequest(ItemStockRequestWorkSheet record) async {
    await ils.delete(record);
  }

  @override
  Future<ItemStockRequestWorkSheet> onChangeReceiveQty({
    required double quantityToReceive,
    required ItemStockRequestWorkSheet record,
  }) async {
    return await ils.writeTransaction((realm) {
      record.quantityToReceive = quantityToReceive;
      return record;
    });
  }

  @override
  Future<List<ItemStockRequestWorkSheet>> updateStockRequest(
    List<ItemStockRequestWorkSheet> records, {
    required String status,
    required String backendStatus,
    List<TransferLine> lines = const [],
    bool isFirstTime = true,
  }) async {
    try {
      return await ils.writeTransaction((realm) {
        for (var record in records) {
          record.status = status;
          record.backendStatus = backendStatus;
          record.updatedAt = DateTime.now().toDateString();

          if (backendStatus == kStatusPosted) {
            record.status = kStatusPosted;
          }

          if (lines.isNotEmpty) {
            final index = lines.indexWhere((e) {
              if (isFirstTime) {
                return e.itemNo == record.itemNo;
              }

              return e.itemNo == record.itemNo &&
                  e.documentNo == record.documentNo &&
                  e.lineNo == record.documentLineNo;
            });

            if (index != -1) {
              final line = lines[index];
              record.quantity = line.quantity;
              record.quantityToShip = line.quantityToShip;
              record.quantityShipped = line.quantityShipped;
              record.quantityToReceive = line.quantityShipped - line.quantityReceived;
              record.quantityReceived = line.quantityReceived;

              if (isFirstTime) {
                record.documentLineNo = line.lineNo;
                record.documentNo = line.documentNo;
                record.transferDocumentNo = line.documentNo;
                record.isSync = kStatusYes;
              }
            }
          }
        }

        return records;
      });
    } catch (e) {
      rethrow;
    }
  }
}
