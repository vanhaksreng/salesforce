import 'package:dartz/dartz.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/errors/failures.dart';
import 'package:salesforce/features/stock/domain/entities/item_worksheet_response.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';

abstract class StockRepository extends BaseAppRepository {
  Future<Either<Failure, List<ItemGroup>>> getItemsGroup({Map<String, dynamic>? param, int page = 1});

  Future<Either<Failure, ItemWorksheetResponse>> getItemRequestWorksheets({Map<String, dynamic>? param});

  Future<Either<Failure, ItemWorksheetResponse>> receiveStockRequest({Map<String, dynamic>? param});

  Future<Either<Failure, ItemWorksheetResponse>> cancelStockRequest({Map<String, dynamic>? param});

  Future<Either<Failure, ItemStockRequestWorkSheet>> onChangeReceiveQty({
    required double quantityToReceive,
    required ItemStockRequestWorkSheet record,
  });

  Future<Either<Failure, ItemStockRequestWorkSheet>> storeStockRequest(
    Item item,
    double quantity, {
    required String itemUomCode,
  });

  Future<Either<Failure, bool>> deleteStockRequest(String itemNo);

  Future<Either<Failure, ItemWorksheetResponse>> submitStockRequest(List<ItemStockRequestWorkSheet> records);
}
