import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/data/repositories/base_app_repository_impl.dart';
import 'package:salesforce/features/stock/data/datasources/api/api_stock_data_source.dart';
import 'package:salesforce/features/stock/data/datasources/realm/realm_stock_data_source.dart';
import 'package:salesforce/features/stock/domain/entities/item_worksheet_response.dart';
import 'package:salesforce/features/stock/domain/entities/transfer_line.dart';
import 'package:salesforce/features/stock/domain/repositories/stock_repository.dart';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/errors/failures.dart';
import 'package:salesforce/infrastructure/network/network_info.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';

class StockRepositoryImpl extends BaseAppRepositoryImpl implements StockRepository {
  final ApiStockDataSource _remote;
  final RealmStockDataSource _local;
  final NetworkInfo _networkInfo;

  StockRepositoryImpl({
    required ApiStockDataSource remote,
    required RealmStockDataSource local,
    required NetworkInfo networkInfo,
  }) : _remote = remote,
       _local = local,
       _networkInfo = networkInfo,
       super(local: local, remote: remote, networkInfo: networkInfo);

  @override
  Future<Either<Failure, List<ItemGroup>>> getItemsGroup({Map<String, dynamic>? param, int page = 1}) async {
    try {
      final items = await _local.getItemsGroups(page: page, param: param);
      return Right(items);
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, ItemWorksheetResponse>> getItemRequestWorksheets({Map<String, dynamic>? param}) async {
    try {
      List<ItemStockRequestWorkSheet> itemWorksheets = [];

      Map<String, dynamic>? p = {'status': 'IN {"$kStatusPending","$kStatusNew"}'};
      if (param != null) {
        p = {...param, ...p};
      }

      itemWorksheets = await _local.getItemRequestWorksheets(data: p);
      if (itemWorksheets.isEmpty) {
        return Right(ItemWorksheetResponse(records: itemWorksheets, headerSatatus: kStatusNew));
      }

      final status = itemWorksheets.first.status;

      if (status != kStatusNew && await _networkInfo.isConnected && await _remote.isValidApiSession()) {
        final results = await _remote.getItemStockWorkSheet(data: {'document_no': itemWorksheets.first.documentNo});

        final List<TransferLine> lines = [];
        for (var item in results["records"]) {
          lines.add(TransferLine.fromMap(item));
        }

        if (lines.isEmpty) {
          return Right(ItemWorksheetResponse(records: itemWorksheets, headerSatatus: results['header_status']));
        }

        itemWorksheets = await _local.updateStockRequest(
          itemWorksheets,
          backendStatus: results['header_status'],
          status: kStatusPending,
          lines: lines,
        );

        return Right(ItemWorksheetResponse(records: itemWorksheets, headerSatatus: results['header_status']));
      }

      return Right(ItemWorksheetResponse(records: itemWorksheets, headerSatatus: kStatusNew));
    } on ServerException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, ItemWorksheetResponse>> receiveStockRequest({Map<String, dynamic>? param}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(CacheFailure(errorInternetMessage));
    }

    if (!await _remote.isValidApiSession()) {
      return const Left(CacheFailure(errorNoAuthMsg));
    }

    Map<String, dynamic>? p = param ?? {};

    List<ItemStockRequestWorkSheet> itemWorksheets = [];
    itemWorksheets = await _local.getItemRequestWorksheets(
      data: {...p, 'quantity_to_receive': '>0', 'quantity': '>0', 'status': kStatusPending},
    );

    if (itemWorksheets.isEmpty) {
      return const Left(CacheFailure("The auantity to receive must greather than zero."));
    }

    final docNo = itemWorksheets.first.documentNo;
    final jsonData = itemWorksheets.map((record) {
      return {
        'line_no': record.documentLineNo,
        'item_no': record.itemNo,
        'quantity_to_receive': record.quantityToReceive,
      };
    }).toList();

    final results = await _remote.receiveStockRequest(data: {'data': jsonEncode(jsonData), 'document_no': docNo});

    final List<TransferLine> lines = [];
    for (var item in results["records"]) {
      lines.add(TransferLine.fromMap(item));
    }

    if (lines.isEmpty) {
      return Right(ItemWorksheetResponse(records: itemWorksheets, headerSatatus: results['header_status']));
    }

    itemWorksheets = await _local.updateStockRequest(
      itemWorksheets,
      backendStatus: results['header_status'],
      status: kStatusPending,
      lines: lines,
    );

    return Right(ItemWorksheetResponse(records: itemWorksheets, headerSatatus: results['header_status']));
  }

  @override
  Future<Either<Failure, ItemWorksheetResponse>> cancelStockRequest({Map<String, dynamic>? param}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(CacheFailure(errorInternetMessage));
    }

    if (!await _remote.isValidApiSession()) {
      return const Left(CacheFailure(errorNoAuthMsg));
    }

    Map<String, dynamic>? p = {'status': 'IN {"$kStatusPending","$kStatusNew"}'};
    if (param != null) {
      p = {...param, ...p};
    }

    List<ItemStockRequestWorkSheet> itemWorksheets = [];
    itemWorksheets = await _local.getItemRequestWorksheets(data: p);

    final docNo = itemWorksheets.first.documentNo;
    final results = await _remote.cancelStockRequest(data: {'document_no': docNo});

    final List<TransferLine> lines = [];
    for (var item in results["records"]) {
      lines.add(TransferLine.fromMap(item));
    }

    if (lines.isEmpty) {
      return Right(ItemWorksheetResponse(records: itemWorksheets, headerSatatus: results['header_status']));
    }

    itemWorksheets = await _local.updateStockRequest(
      itemWorksheets,
      backendStatus: results['header_status'],
      status: kStatusClose,
      lines: lines,
    );

    return Right(ItemWorksheetResponse(records: itemWorksheets, headerSatatus: results['header_status']));
  }

  @override
  Future<Either<Failure, ItemStockRequestWorkSheet>> onChangeReceiveQty({
    required double quantityToReceive,
    required ItemStockRequestWorkSheet record,
  }) async {
    try {
      final result = await _local.onChangeReceiveQty(quantityToReceive: quantityToReceive, record: record);

      return Right(result);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, ItemStockRequestWorkSheet>> storeStockRequest(
    Item item,
    double quantity, {
    required String itemUomCode,
  }) async {
    try {
      final uom = await _local.getItemUom(params: {"item_no": item.no, "unit_of_measure_code": itemUomCode});

      if (uom == null) {
        throw GeneralException(
          "Unit of Measure for item [${item.no}] not found. Please download the master data to ensure your data is up to date.",
        );
      }

      ItemStockRequestWorkSheet? worksheet;
      worksheet = await _local.getItemRequestWorksheet(data: {"itemNo": item.no, 'status': 'New'});

      final double qtyPerUnit = uom.qtyPerUnit ?? 1.0;

      if (worksheet == null) {
        final userSetup = await _local.getUserSetup();
        final id = Helpers.generateDocumentNo("${userSetup?.userId ?? 1}");

        worksheet = ItemStockRequestWorkSheet(
          id,
          item.no,
          appId: id,
          qtyPerUnitOfMeasure: qtyPerUnit,
          unitOfMeasureCode: itemUomCode,
          description: item.description,
          description2: item.description2,
          fromLocationCode: userSetup?.fromLocationCode,
          locationCode: userSetup?.locationCode,
          postingDate: DateTime.now().toDateString(),
          createdAt: DateTime.now().toDateString(),
          purchaserCode: userSetup?.salespersonCode,
          backendStatus: kStatusOpen,
          isSync: kStatusNo,
        );
      }

      await _local.storeStockRequest(worksheet, quantity: quantity, uomCode: itemUomCode, qtyPerUnit: qtyPerUnit);

      return Right(worksheet);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteStockRequest(String itemNo) async {
    try {
      final worksheet = await _local.getItemRequestWorksheet(data: {"itemNo": itemNo, 'status': 'New'});

      if (worksheet == null) {
        throw GeneralException("Record not found.");
      }

      await _local.deleteStockRequest(worksheet);
      return const Right(true);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, ItemWorksheetResponse>> submitStockRequest(List<ItemStockRequestWorkSheet> records) async {
    //Check internet connection
    if (!await _networkInfo.isConnected) {
      return const Left(CacheFailure(errorInternetMessage));
    }

    //Check api session
    if (!await _remote.isValidApiSession()) {
      return const Left(CacheFailure(errorNoAuthMsg));
    }

    try {
      final jsonData = records.map((record) {
        return {
          'id': record.id,
          'item_no': record.itemNo,
          'unit_of_measure_code': record.unitOfMeasureCode,
          'quantity': record.quantity,
        };
      }).toList();

      final results = await _remote.submitStockRequest({'data': jsonEncode(jsonData)});

      final List<TransferLine> lines = [];
      for (var item in results["records"]) {
        lines.add(TransferLine.fromMap(item));
      }

      records = await _local.updateStockRequest(
        records,
        status: kStatusPending,
        backendStatus: results['header_status'],
        lines: lines,
        isFirstTime: true,
      );

      return Right(ItemWorksheetResponse(headerSatatus: results['header_status'], records: records));
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception {
      return Left(ServerFailure(errorMessage));
    }
  }
}
