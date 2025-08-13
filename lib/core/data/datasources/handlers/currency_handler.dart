import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/currency_extension.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class CurrencyHandler extends BaseTableHandler<Currency> {
  @override
  String get tableName => "currency";

  @override
  Currency fromMap(Map<String, dynamic> map) {
    return CurrencyExtension.fromMap(map);
  }

  @override
  String extractKey(Currency record) => record.code;

  @override
  Type get type => Currency;
}
