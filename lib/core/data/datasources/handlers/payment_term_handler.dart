import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/payment_term_extension.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class PaymentTermHandler extends BaseTableHandler<PaymentTerm> {
  @override
  String get tableName => "payment_term";

  @override
  PaymentTerm fromMap(Map<String, dynamic> map) {
    return PaymentTermExtension.fromMap(map);
  }

  @override
  String extractKey(PaymentTerm record) => record.code;

  @override
  Type get type => PaymentTerm;
}
