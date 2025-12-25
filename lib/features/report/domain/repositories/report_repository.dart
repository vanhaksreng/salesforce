import 'package:dartz/dartz.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/errors/failures.dart';
import 'package:salesforce/features/report/domain/entities/customer_balance_report.dart';
import 'package:salesforce/features/report/domain/entities/daily_sale_sumary_report_model.dart';
import 'package:salesforce/features/report/domain/entities/so_outstanding_report_model.dart';
import 'package:salesforce/features/report/domain/entities/stock_request_report_model.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

abstract class ReportRepository extends BaseAppRepository {
  // Future<Either<Failure, List<PosSalesHeader>>> getSaleHeaders({
  //   Map<String, dynamic>? param,
  //   int page = 1,
  //   bool fetchingApi = true,
  // });

  // Future<Either<Failure, List<PosSalesLine>>> getSaleLines({
  //   Map<String, dynamic>? param,
  //   int page = 1,
  //   bool fetchingApi = true,
  // });

  // Future<Either<Failure, SaleDetail>> getSaleDetails({
  //   Map<String, dynamic>? param,
  // });

  Future<Either<Failure, List<Salesperson>>> getSalespersons({Map<String, dynamic>? param});

  Future<Either<Failure, List<SoOutstandingReportModel>>> getSoOutstandingReport({
    Map<String, dynamic>? param,
    int page = 1,
  });

  Future<Either<Failure, List<DailySaleSumaryReportModel>>> getDailySalesSummaryReport({
    Map<String, dynamic>? param,
    int page = 1,
  });

  Future<Either<Failure, Map<String, dynamic>>> getItemInventoryReport({Map<String, dynamic>? param, int page = 1});

  Future<Either<Failure, List<StockRequestReportModel>>> getStockRequestReport({
    Map<String, dynamic>? param,
    int page = 1,
  });

  Future<Either<Failure, List<CustomerBalanceReport>>> getCustomerBalanceReport({
    Map<String, dynamic>? param,
    int page = 1,
  });
}
