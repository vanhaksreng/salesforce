import 'package:salesforce/core/data/datasources/api/base_api_data_source.dart';

abstract class ApiStockDataSource extends BaseApiDataSource {
  Future<Map<String, dynamic>> submitStockRequest(Map<String, dynamic> data);

  Future<Map<String, dynamic>> getItemStockWorkSheet({Map<String, dynamic>? data});

  Future<Map<String, dynamic>> receiveStockRequest({Map<String, dynamic>? data});

  Future<Map<String, dynamic>> cancelStockRequest({Map<String, dynamic>? data});
}
