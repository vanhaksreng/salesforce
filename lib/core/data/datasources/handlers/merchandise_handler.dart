import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/merchandise_extension.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class MerchandiseHandler extends BaseTableHandler<Merchandise> {
  @override
  String get tableName => "merchandise";

  @override
  Merchandise fromMap(Map<String, dynamic> map) => MerchandiseExtension.fromMap(map);

  @override
  String extractKey(Merchandise record) => record.code;

  @override
  Type get type => Merchandise;
}
