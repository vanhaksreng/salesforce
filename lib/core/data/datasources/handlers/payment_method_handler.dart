import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/payment_method_extension.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class PaymentMethodHandler extends BaseTableHandler<PaymentMethod> {
  @override
  String get tableName => "payment_term";

  @override
  PaymentMethod fromMap(Map<String, dynamic> map) {
    return PaymentMethodExtension.fromMap(map);
  }

  @override
  String extractKey(PaymentMethod record) => record.code;

  @override
  Type get type => PaymentTerm;
}
