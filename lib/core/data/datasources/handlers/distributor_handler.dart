import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/distributor_extension.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class DistributorHandler extends BaseTableHandler<Distributor> {
  @override
  String get tableName => "distributor";

  @override
  Distributor fromMap(Map<String, dynamic> map) {
    return DistributorExtension.fromMap(map);
  }

  @override
  String extractKey(Distributor record) => record.code;

  @override
  Type get type => Distributor;
}
