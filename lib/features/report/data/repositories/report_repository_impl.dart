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
    required ApiReportDataSource remote,
    required RealmReportDataSource local,
    required NetworkInfo networkInfo,
  }) : _remote = remote,
       _local = local,
       _networkInfo = networkInfo,
       super(local: local, remote: remote, networkInfo: networkInfo);
  // @override
  // Future<Either<Failure, List<PosSalesHeader>>> getSaleHeaders({
  //   Map<String, dynamic>? param,
  //   int page = 1,
  //   bool fetchingApi = true,
  // }) async {
  //   try {
  //     final localSale = await _local.getSaleHeaders(
  //       data: param,
  //     );

  //     if (fetchingApi && await _networkInfo.isConnected) {
  //       param?['page'] = page;
  //       final cloudSales = await _remote.getSaleHeaders(data: param);

  //       if (localSale.length == cloudSales.length) {
  //         return Right(localSale);
  //       }

  //       final localIds = localSale.map((e) => e.id).toSet();

  //       final newSales = cloudSales.where((s) {
  //         return !localIds.contains(s.id);
  //       }).toList();

  //       _local.storeSaleHeaders(newSales);

  //       return Right(cloudSales);
  //     }

  //     return Right(localSale);
  //   } on GeneralException {
  //     return const Left(CacheFailure(errorInternetMessage));
  //   }
  // }

  // @override
  // Future<Either<Failure, List<PosSalesLine>>> getSaleLines({
  //   Map<String, dynamic>? param,
  //   int page = 1,
  //   bool fetchingApi = true,
  // }) async {
  //   try {
  //     final localeSaleLines = await _local.getSaleLines(data: param);

  //     if (fetchingApi && await _networkInfo.isConnected) {
  //       param?['page'] = page;
  //       final saleLineCloud = await _remote.getSaleLines(data: param);

  //       final localIds = localeSaleLines.map((e) => e.id).toSet();

  //       final newSaleLines = saleLineCloud.where((s) {
  //         return !localIds.contains(s.id);
  //       }).toList();

  //       _local.storeLines(newSaleLines);
  //       return Right(saleLineCloud);
  //     }

  //     return const Right([]);
  //   } on GeneralException {
  //     return const Left(CacheFailure(errorInternetMessage));
  //   }
  // }

  // @override
  // Future<Either<Failure, SaleDetail>> getSaleDetails({
  //   Map<String, dynamic>? param,
  // }) async {
  //   try {
  //     if (await _networkInfo.isConnected) {
  //       final sales = await _remote.getSaleDetails(data: param);
  //       return Right(sales);
  //     }

  //     return const Left(CacheFailure(errorInternetMessage));
  //   } on GeneralException {
  //     return const Left(CacheFailure(errorInternetMessage));
  //   }
  // }

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
