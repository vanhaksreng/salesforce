import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/data/datasources/api/base_api_data_source.dart';
import 'package:salesforce/core/data/datasources/handlers/table_handler_factory.dart';
import 'package:salesforce/core/data/datasources/realm/base_realm_data_source.dart';
import 'package:salesforce/core/data/models/extension/company_info_extension.dart';
import 'package:salesforce/core/data/models/extension/gps_tracking_entry_extension.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/errors/failures.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/infrastructure/network/network_info.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class BaseAppRepositoryImpl implements BaseAppRepository {
  final BaseApiDataSource _remote;
  final BaseRealmDataSource _local;
  final NetworkInfo _networkInfo;

  const BaseAppRepositoryImpl({
    required BaseApiDataSource remote,
    required BaseRealmDataSource local,
    required NetworkInfo networkInfo,
  }) : _remote = remote,
       _local = local,
       _networkInfo = networkInfo;

  @override
  Future<void> storeAppSyncLog() async {
    try {
      await _local.storeAppSyncLog();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, List<AppSyncLog>>> getAppSyncLogs({
    Map<String, dynamic>? arg,
  }) async {
    try {
      final download = await _local.getAppSyncLogs(arg: arg);
      return Right(download);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, bool>> downloadTranData({
    required List<AppSyncLog> tables,
    Function(double, int, String, String)? onProgress,
    Map<String, dynamic>? param,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(CacheFailure(errorInternetMessage));
    }

    int countErrors = 0;
    int excuted = 0;
    final countTables = tables.length;
    String errorText = '';

    try {
      await _remote.checkApiSession();

      for (var table in tables) {
        errorText = '';
        excuted += 1;
        final String displayName = table.displayName ?? table.tableName;

        try {
          final tableName = table.tableName;
          final handler = TableHandlerFactory.getHandler(tableName);

          if (handler == null) {
            return throw GeneralException(
              "No handler found for table: $tableName",
            );
          }

          Map<String, dynamic>? p = {
            "table": tableName,
            "last_synched_datetime": table.lastSynchedDatetime,
          };

          if (param != null) {
            p = {...p, ...param};
          }

          final datas = await _remote.downloadTranData(data: p);

          final date = datas['datetime'] as String;

          final records = (datas["records"] as List).map((item) {
            return handler.fromMap(item as Map<String, dynamic>);
          }).toList();

          final reset = datas["reset"] ?? false;
          await _local.storeData(
            records,
            handler.extractKey,
            date,
            tableName,
            reset: reset,
          );
        } catch (e) {
          errorText = "$displayName Error: ${e.toString()}";
          countErrors++;

          if (countErrors > 3) {
            //TODO : do something
          }
        }

        String textMsg = "${displayName.toLowerCase()}...";
        if (countErrors > 0) {
          textMsg =
              "${displayName.toLowerCase()}...(Failed : $countErrors / $countTables)";
        }

        double percent = (excuted / countTables) * 100;
        if (onProgress != null) {
          onProgress(percent, countTables, textMsg, errorText);
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }

      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<bool> hasPermission(String name) async {
    final permission = await _local.getPermission(param: {'key': name});
    if (permission == null) {
      return false;
    }

    if (permission.value == kStatusYes) {
      return true;
    }

    return false;
  }

  @override
  Future<String> getSetting(String settingKey) async {
    final permission = await _local.getSetting(settingKey);
    return Helpers.toStrings(permission?.value);
  }

  @override
  Future<Either<Failure, bool>> downloadAppSetting() async {
    if (!await _networkInfo.isConnected) {
      return const Left(CacheFailure("No internet connection"));
    }

    try {
      await _remote.checkApiSession();
      final result = await _remote.downloadAppSetting();
      await _local.storeInitAppData(result);

      return const Right(true);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, bool>> isValidApiSession() async {
    final result = await _remote.isValidApiSession();
    return Right(result);
  }

  @override
  Future<Either<Failure, List<Customer>>> getCustomers({
    int page = 1,
    Map<String, dynamic>? params,
  }) async {
    try {
      final customer = await _local.getCustomers(page: page, params: params);
      return Right(customer);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, List<Item>>> getItems({
    Map<String, dynamic>? param,
    int page = 1,
  }) async {
    try {
      final items = await _local.getItems(page: page, param: param);
      return Right(items);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, Item?>> getItem({Map<String, dynamic>? param}) async {
    try {
      final item = await _local.getItem(param: param);
      return Right(item);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, ItemUnitOfMeasure?>> getItemUom({
    Map<String, dynamic>? params,
    int page = 1,
  }) async {
    try {
      final itemUom = await _local.getItemUom(params: params);
      return Right(itemUom);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, List<ItemUnitOfMeasure>>> getItemUoms({
    Map<String, dynamic>? params,
  }) async {
    try {
      final itemUoms = await _local.getItemUoms(params: params);
      return Right(itemUoms);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, UserSetup?>> getUserSetup({
    Map<String, dynamic>? params,
  }) async {
    try {
      final userSetup = await _local.getUserSetup(param: params);
      return Right(userSetup);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isConnectedToNetwork() async {
    return await _networkInfo.isConnected;
  }

  @override
  Future<Either<Failure, List<ItemPromotionHeader>>> getItemPromotionHeaders({
    Map<String, dynamic>? params,
  }) async {
    try {
      final promotionHeader = await _local.getItemPromotionHeaders(
        args: params,
      );
      return Right(promotionHeader);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, List<ItemPromotionLine>>> getItemPromotionLines({
    Map<String, dynamic>? params,
  }) async {
    try {
      final promotionLines = await _local.getItemPromotionLines(args: params);
      return Right(promotionLines);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, ItemPromotionScheme?>> getPromotionScheme({
    Map<String, dynamic>? params,
  }) async {
    try {
      final scheme = await _local.getPromotionScheme(args: params);
      return Right(scheme);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, bool>> storeLocationOffline(LatLng latlng) async {
    final UserSetup? user = await _local.getUserSetup();

    try {
      final locationData = GpsRouteTracking(
        user?.salespersonCode ?? "",
        latlng.latitude,
        latlng.longitude,
        DateTime.now().toDateString(),
        DateTime.now().toDateTimeString(),
        isSync: "No",
      );

      await _local.storeLocationOffline(locationData);

      return const Right(true);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, bool>> storeGps(List<GpsRouteTracking> records) async {
    try {
      await _local.storeGps(records);
      return const Right(true);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, bool>> syncOfflineLocationToBackend() async {
    if (!await _networkInfo.isConnected) {
      return const Right(true);
    }

    final routeTrackings = await _local.getGPSRouteTracking(
      param: {"is_sync": "No"},
    );

    if (routeTrackings.isEmpty) {
      return const Right(true);
    }

    try {
      List<Map<String, dynamic>> jsonData = routeTrackings.map((record) {
        return {
          'salesperson_code': record.salepersonCode,
          "latitude": record.latitude,
          "longitude": record.longitude,
          "created_date": record.createdDate,
          "created_time": record.createdTime,
        };
      }).toList();

      await _remote.gpsTrackingEntry(data: {'data': jsonEncode(jsonData)});

      await _local.updateTrackingByCreatedDate(routeTrackings);

      return const Right(true);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, Salesperson?>> getSaleperson({
    Map<String, dynamic>? params,
  }) async {
    try {
      final saleperson = await _local.getSalesperson(args: params);
      return Right(saleperson);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, List<Salesperson>>> getSalepersons({
    Map<String, dynamic>? params,
  }) async {
    try {
      final saleperson = await _local.getSalespersons(args: params);
      return Right(saleperson);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> gpsTrackingEntry({required Map<String, dynamic> params}) async {
    try {
      if (!await _networkInfo.isConnected) {
        return;
      }

      await _remote.gpsTrackingEntry(data: params);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateProfileInfo({required Map<String, dynamic> params}) async {
    try {
      if (!await _networkInfo.isConnected) {
        throw GeneralException(errorInternetMessage);
      }

      await _remote.updateProfileUer(data: params, imagePath: params["file"]);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, bool>> clearAllData(List<AppSyncLog> tables) async {
    try {
      await _local.clearAllData(tables);
      return const Right(true);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> heartbeatStatus({required Map<String, dynamic> params}) async {
    try {
      if (!await _networkInfo.isConnected) {
        return;
      }

      await _remote.heartbeatStatus(data: params);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, GpsRouteTracking?>> getLastGpsRequest() async {
    try {
      final response = await _local.getLastGpsRequest();
      return Right(response);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompanyInformation?>> getCompanyInfo() async {
    try {
      final response = await _local.getCompanyInfo();
      return Right(response);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompanyInformation?>> getRemoteCompanyInfo({
    required Map<String, dynamic> params,
  }) async {
    try {
      final response = await _remote.getCompanyInfo(data: params);

      final companyInfo = CompanyInformationExtension.fromMap(
        response["records"],
      );
      await _local.storeCompanyInfo(companyInfo);
      print("===========hiii==========${companyInfo}");
      return Right(companyInfo);
    } catch (e) {
      Logger.log("getRemoteCompanyInfo $e");
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> processUploadGpsTracking() async {
    try {
      final records = await _local.getGPSTrackingEntries(
        param: {'is_sync': kStatusNo},
      );

      List<Map<String, dynamic>> jsonData = [];
      for (var record in records) {
        jsonData.add(record.toJson());
      }

      if (jsonData.isEmpty) {
        return const Left(CacheFailure("Nothing to upload"));
      }

      await _remote.processUpload(
        data: {
          'table_name': 'gps_tracking_entry',
          'data': jsonEncode(jsonData),
        },
      );

      await _local.updateStatusGPSTrackingEntries(records: records);

      return Right(true);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
