import 'package:salesforce/core/data/datasources/api/base_api_data_source_impl.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/features/report/data/datasources/api/api_report_data_source.dart';
import 'package:salesforce/features/report/domain/entities/customer_balance_report.dart';
import 'package:salesforce/features/report/domain/entities/daily_sale_sumary_report_model.dart';
import 'package:salesforce/features/report/domain/entities/so_outstanding_report_model.dart';
import 'package:salesforce/features/report/domain/entities/stock_request_report_model.dart';

class ApiReportDataSourceImpl extends BaseApiDataSourceImpl implements ApiReportDataSource {
  ApiReportDataSourceImpl({required super.network});

  @override
  Future<List<DailySaleSumaryReportModel>> getDailySalesSummaryReport({Map<String, dynamic>? param}) async {
    try {
      final response = await apiClient.post('v2/report-daily-sales-summary', body: await getParams(params: param));

      final List<DailySaleSumaryReportModel> records = [];
      for (var record in response['records']) {
        records.add(DailySaleSumaryReportModel.fromJson(record));
      }
      return records;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SoOutstandingReportModel>> getSoOutstandingReport({Map<String, dynamic>? data}) async {
    try {
      final response = await apiClient.post('v2/get-so-outstanding-report', body: await getParams(params: data));

      final List<SoOutstandingReportModel> records = [];
      for (var record in response["records"]) {
        records.add(SoOutstandingReportModel.fromMap(record));
      }
      return records;
    } catch (e, stackTrace) {
      Logger.log('Error in getSoOutstandingReport: $e');
      Logger.log('StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getItemInventoryReport({Map<String, dynamic>? param}) async {
    try {
      final response = await apiClient.post('v2/report-item-inventory', body: await getParams(params: param));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<StockRequestReportModel>> getStockRequestReport({Map<String, dynamic>? param}) async {
    try {
      final response = await apiClient.post('v2/report-stock-request', body: await getParams(params: param));
      final List<StockRequestReportModel> records = [];
      for (var record in response["records"]) {
        records.add(StockRequestReportModel.fromJson(record));
      }
      return records;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CustomerBalanceReport>> getCustomerBalanceReport({Map<String, dynamic>? param}) async {
    try {
      final response = await apiClient.post('v2/report-customer-balance-summary', body: await getParams(params: param));
      final List<CustomerBalanceReport> records = [];
      for (var record in response["records"]) {
        records.add(CustomerBalanceReport.fromJson(record));
      }
      return records;
    } catch (e) {
      rethrow;
    }
  }
}
