import 'package:salesforce/core/data/datasources/api/base_api_data_source.dart';
import 'package:salesforce/features/report/domain/entities/customer_balance_report.dart';
import 'package:salesforce/features/report/domain/entities/daily_sale_sumary_report_model.dart';
import 'package:salesforce/features/report/domain/entities/so_outstanding_report_model.dart';
import 'package:salesforce/features/report/domain/entities/stock_request_report_model.dart';

abstract class ApiReportDataSource extends BaseApiDataSource {
  Future<List<DailySaleSumaryReportModel>> getDailySalesSummaryReport({Map<String, dynamic>? param});

  Future<List<SoOutstandingReportModel>> getSoOutstandingReport({Map<String, dynamic>? data});

  Future<Map<String, dynamic>> getItemInventoryReport({Map<String, dynamic>? param});

  Future<List<StockRequestReportModel>> getStockRequestReport({Map<String, dynamic>? param});

  Future<List<CustomerBalanceReport>> getCustomerBalanceReport({Map<String, dynamic>? param});
}
