import 'package:salesforce/core/data/datasources/api/base_api_data_source.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';

abstract class ApiMoreDataSource extends BaseApiDataSource {
  Future<Map<String, dynamic>> getSaleHeaders({Map<String, dynamic>? data});

  Future<List<SalesLine>> getSaleLines({Map<String, dynamic>? data});

  Future<SaleDetail?> getSaleDetails({Map<String, dynamic>? data});

  Future<Map<String, dynamic>> createNewCustomer({Map<String, dynamic>? data});

  Future<Map<String, dynamic>> updateCustomer({Map<String, dynamic>? data});

  Future<Map<String, dynamic>> createNewCustomerAddress({
    Map<String, dynamic>? data,
  });

  Future<Map<String, dynamic>> updateCustomerAddress({
    Map<String, dynamic>? data,
  });

  Future<Map<String, dynamic>> deleteCustomerAddress({
    Map<String, dynamic>? data,
  });

  Future<Map<String, dynamic>> getAddressFromLatLng(double lat, double lng);

  Future<Map<String, dynamic>> resetPassword({Map<String, dynamic>? data});

  Future<Map<String, dynamic>> logout({Map<String, dynamic>? data});

  Future<Map<String, dynamic>> getInvoiceHtml({Map<String, dynamic>? data});
  Future<List<SalesLine>> getSaleLinesV2({Map<String, dynamic>? data});
}
