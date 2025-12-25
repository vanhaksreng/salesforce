import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/competitor_item_extension.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';

class CompetitorItemHandler extends BaseTableHandler<CompetitorItem> {
  @override
  String get tableName => "competitor_item";

  @override
  CompetitorItem fromMap(Map<String, dynamic> map) {
    return CompetitorItemExtension.fromMap(map);
  }

  @override
  String extractKey(CompetitorItem record) => record.no;

  @override
  Type get type => CompetitorItem;
}
