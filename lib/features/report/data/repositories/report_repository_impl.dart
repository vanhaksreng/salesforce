import 'package:dartz/dartz.dart';
import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/data/repositories/base_app_repository_impl.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/errors/failures.dart';
import 'package:salesforce/features/report/data/datasources/api/api_report_data_source.dart';
import 'package:salesforce/features/report/data/datasources/realm/realm_report_data_source.dart';
import 'package:salesforce/features/report/domain/entities/customer_balance_report.dart';
import 'package:salesforce/features/report/domain/entities/daily_sale_sumary_report_model.dart';
import 'package:salesforce/features/report/domain/entities/item_inventory_report_model.dart';
import 'package:salesforce/features/report/domain/entities/so_outstanding_report_model.dart';
import 'package:salesforce/features/report/domain/entities/stock_request_report_model.dart';
import 'package:salesforce/features/report/domain/repositories/report_repository.dart';
import 'package:salesforce/infrastructure/network/network_info.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class ReportRepositoryImpl extends BaseAppRepositoryImpl implements ReportRepository {
  final ApiReportDataSource _remote;
  final RealmReportDataSource _local;
  final NetworkInfo _networkInfo;

  ReportRepositoryImpl({
    required ApiReportDataSource super.remote,
    required RealmReportDataSource super.local,
    required super.networkInfo,
  }) : _remote = remote,
       _local = local,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<Salesperson>>> getSalespersons({Map<String, dynamic>? param}) async {
    try {
      final salerPersons = await _local.getSalespersons(args: param);
      return Right(salerPersons);
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, List<SoOutstandingReportModel>>> getSoOutstandingReport({
    Map<String, dynamic>? param,
    int page = 1,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        param?['page'] = page;
        final soOutstandingReport = await _remote.getSoOutstandingReport(data: param);
        return Right(soOutstandingReport);
      }
      return const Right([]);
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, List<DailySaleSumaryReportModel>>> getDailySalesSummaryReport({
    Map<String, dynamic>? param,
    int page = 1,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        param?['page'] = page;
        final dailSalesSummaryReport = await _remote.getDailySalesSummaryReport(param: param);

        return Right(dailSalesSummaryReport);
      }
      return const Right([]);
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getItemInventoryReport({
    Map<String, dynamic>? param,
    int page = 1,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        param?['page'] = page;
        final data = await _remote.getItemInventoryReport(param: param);

        final List<ItemInventoryReportModel> records = [];

        for (var item in data["records"]) {
          records.add(ItemInventoryReportModel.fromJson(item));
        }

        return Right({"data": records, "filter_note": data["filter_note"]});
      }
      return const Right({});
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, List<StockRequestReportModel>>> getStockRequestReport({
    Map<String, dynamic>? param,
    int page = 1,
  }) async {
    try {
      final recordReportStockRequest = await _remote.getStockRequestReport(param: param);
      return Right(recordReportStockRequest);
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, List<CustomerBalanceReport>>> getCustomerBalanceReport({
    Map<String, dynamic>? param,
    int page = 1,
  }) async {
    try {
      final recordCustomerBalance = await _remote.getCustomerBalanceReport(param: param);
      return Right(recordCustomerBalance);
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }
}
