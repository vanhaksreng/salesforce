import 'package:salesforce/core/data/datasources/api/base_api_data_source_impl.dart';
import 'package:salesforce/features/stock/data/datasources/api/api_stock_data_source.dart';

class ApiStockDataSourceImpl extends BaseApiDataSourceImpl implements ApiStockDataSource {
  ApiStockDataSourceImpl({required super.network});

  @override
  Future<bool> isValidApiSession() async {
    try {
      await apiClient.postCheckSession('v2/check-api-session', body: await getParams());

      return true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> submitStockRequest(Map<String, dynamic> data) async {
    try {
      return await apiClient.post('v2/submit-stock-request', body: await getParams(params: data));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getItemStockWorkSheet({Map<String, dynamic>? data}) async {
    try {
      final response = await apiClient.post('v2/get-stock-work-sheet', body: await getParams(params: data));

      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> receiveStockRequest({Map<String, dynamic>? data}) async {
    try {
      final response = await apiClient.post('v2/receive-stock-request', body: await getParams(params: data));

      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> cancelStockRequest({Map<String, dynamic>? data}) async {
    try {
      final response = await apiClient.post('v2/cancel-stock-request', body: await getParams(params: data));

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
