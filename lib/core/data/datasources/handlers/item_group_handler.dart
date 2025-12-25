import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/item_group_extension.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';

class ItemGroupHandler extends BaseTableHandler<ItemGroup> {
  @override
  String get tableName => "item_group";

  @override
  ItemGroup fromMap(Map<String, dynamic> map) => ItemGroupExtension.fromMap(map);

  @override
  String extractKey(ItemGroup record) => record.code;

  @override
  Type get type => ItemGroup;
}
