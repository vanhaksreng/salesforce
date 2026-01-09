import 'dart:convert';

import 'package:salesforce/core/data/datasources/api/base_api_data_source_impl.dart';
import 'package:salesforce/core/data/models/extension/sale_header_extension.dart';
import 'package:salesforce/core/data/models/extension/sale_line_extension.dart';
import 'package:salesforce/env.dart';
import 'package:salesforce/features/more/data/datasources/api/api_more_data_source.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:http/http.dart' as http;

class ApiMoreDataSourceImpl extends BaseApiDataSourceImpl
    implements ApiMoreDataSource {
  ApiMoreDataSourceImpl({required super.network});

  @override
  Future<Map<String, dynamic>> getSaleHeaders({
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await apiClient.post(
        'v2/get-sale-histories',
        body: await getParams(params: data),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SalesLine>> getSaleLines({Map<String, dynamic>? data}) async {
    try {
      final response = await apiClient.post(
        'v2/get-sale-lines',
        body: await getParams(params: data),
      );
      final List<SalesLine> records = [];
      for (var item in response["records"]) {
        records.add(SalesLineExtension.fromMap(item));
      }

      return records;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SalesLine>> getSaleLinesV2({Map<String, dynamic>? data}) async {
    try {
      final response = await apiClient.post(
        'v2/get-sale-lines-v2',
        body: await getParams(params: data),
      );
      final List<SalesLine> records = [];
      for (var item in response["records"]) {
        records.add(SalesLineExtension.fromMap(item));
      }

      return records;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SaleDetail> getSaleDetails({Map<String, dynamic>? data}) async {
    try {
      final response = await apiClient.post(
        'v2/get-sale-detail-history',
        body: await getParams(params: data),
      );

      final List<SalesLine> records = [];
      for (var item in response["lines"]) {
        records.add(SalesLineExtension.fromMap(item));
      }

      return SaleDetail(
        header: SalesHeaderExtension.fromMap(response["header"]),
        lines: records,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getAddressFromLatLng(
    double lat,
    double lng,
  ) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$kGoogleKey',
    );

    final response = await http.get(url);
    return json.decode(response.body);
  }

  @override
  Future<Map<String, dynamic>> createNewCustomer({
    Map<String, dynamic>? data,
  }) async {
    try {
      return await apiClient.post(
        'v2/create-new-customer',
        body: await getParams(params: data),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateCustomer({
    Map<String, dynamic>? data,
  }) async {
    try {
      return await apiClient.post(
        'v2/update-customer',
        body: await getParams(params: data),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> createNewCustomerAddress({
    Map<String, dynamic>? data,
  }) async {
    try {
      return await apiClient.post(
        'v2/create-new-customer-address',
        body: await getParams(params: data),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateCustomerAddress({
    Map<String, dynamic>? data,
  }) async {
    try {
      return await apiClient.post(
        'v2/update-customer-address',
        body: await getParams(params: data),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> deleteCustomerAddress({
    Map<String, dynamic>? data,
  }) async {
    try {
      return await apiClient.post(
        'v2/delete-customer-address',
        body: await getParams(params: data),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> resetPassword({
    Map<String, dynamic>? data,
  }) async {
    try {
      return await apiClient.post(
        'v2/reset-password',
        body: await getParams(params: data),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> logout({Map<String, dynamic>? data}) async {
    try {
      return await apiClient.post(
        'v2/update-customer',
        body: await getParams(params: data),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getInvoiceHtml({
    Map<String, dynamic>? data,
  }) async {
    try {
      return await apiClient.post(
        'v2/get-invoice-html',
        body: await getParams(params: data),
      );
    } catch (e) {
      rethrow;
    }
  }
}
