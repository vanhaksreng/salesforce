import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/errors/failures.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

abstract class BaseAppRepository {
  Future<Either<Failure, bool>> downloadTranData({
    required List<AppSyncLog> tables,
    Function(double, int, String, String)? onProgress,
    Map<String, dynamic>? param,
  });

  Future<Either<Failure, bool>> isValidApiSession();

  Future<Either<Failure, bool>> downloadAppSetting();

  Future<bool> hasPermission(String name);
  Future<String> getSetting(String settingKey);

  Future<void> storeAppSyncLog();
  Future<Either<Failure, List<AppSyncLog>>> getAppSyncLogs({
    Map<String, dynamic>? arg,
  });

  Future<Either<Failure, List<Customer>>> getCustomers({
    int page = 1,
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, List<Item>>> getItems({
    Map<String, dynamic>? param,
    int page = 1,
  });

  Future<Either<Failure, Item?>> getItem({Map<String, dynamic>? param});

  Future<Either<Failure, ItemUnitOfMeasure?>> getItemUom({
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, List<ItemUnitOfMeasure>>> getItemUoms({
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, UserSetup?>> getUserSetup({
    Map<String, dynamic>? params,
  });

  Future<bool> isConnectedToNetwork();

  Future<Either<Failure, List<ItemPromotionHeader>>> getItemPromotionHeaders({
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, List<ItemPromotionLine>>> getItemPromotionLines({
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, ItemPromotionScheme?>> getPromotionScheme({
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, bool>> storeLocationOffline(LatLng latlng);
  Future<Either<Failure, bool>> storeGps(List<GpsRouteTracking> records);
  Future<Either<Failure, bool>> syncOfflineLocationToBackend();

  Future<Either<Failure, Salesperson?>> getSaleperson({
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, List<Salesperson>>> getSalepersons({
    Map<String, dynamic>? params,
  });

  Future<void> gpsTrackingEntry({required Map<String, dynamic> params});

  Future<void> updateProfileInfo({required Map<String, dynamic> params});

  Future<Either<Failure, bool>> clearAllData(List<AppSyncLog> tables);

  Future<void> heartbeatStatus({required Map<String, dynamic> params});

  Future<Either<Failure, GpsRouteTracking?>> getLastGpsRequest();

  Future<Either<Failure, CompanyInformation?>> getCompanyInfo();
  Future<Either<Failure, CompanyInformation?>> getRemoteCompanyInfo({
    required Map<String, dynamic> params,
  });

  Future<Either<Failure, bool>> processUploadGpsTracking();
}
