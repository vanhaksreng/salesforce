import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/competitor_extension.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class CompetitorHandler extends BaseTableHandler<Competitor> {
  @override
  String get tableName => "bank_account";

  @override
  Competitor fromMap(Map<String, dynamic> map) {
    return CompetitorExtension.fromMap(map);
  }

  @override
  String extractKey(Competitor record) => record.no;

  @override
  Type get type => Competitor;
}
