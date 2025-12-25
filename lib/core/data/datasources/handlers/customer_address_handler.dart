import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/customer_address_extension.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class CustomerAddressHandler extends BaseTableHandler<CustomerAddress> {
  @override
  String get tableName => "customer_address";

  @override
  CustomerAddress fromMap(Map<String, dynamic> map) {
    return CustomerAddressExtension.fromMap(map);
  }

  @override
  String extractKey(CustomerAddress record) => record.id;

  @override
  Type get type => CustomerAddress;
}
