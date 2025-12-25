import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/item_extension.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';

class ItemHandler extends BaseTableHandler<Item> {
  @override
  String get tableName => "item";

  @override
  Item fromMap(Map<String, dynamic> map) => ItemExtension.fromMap(map);

  @override
  String extractKey(Item record) => record.no;

  @override
  Type get type => Item;
}
