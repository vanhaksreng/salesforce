import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/customer_extension.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class CustomerHandler extends BaseTableHandler<Customer> {
  @override
  String get tableName => "customer";

  @override
  Customer fromMap(Map<String, dynamic> map) {
    return CustomerExtension.fromMap(map);
  }

  @override
  String extractKey(Customer record) => record.no;

  @override
  Type get type => Customer;
}
