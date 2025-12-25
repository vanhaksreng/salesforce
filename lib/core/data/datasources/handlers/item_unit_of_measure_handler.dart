import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/item_unit_of_measure_extension.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';

class ItemUnitOfMeasureHandler extends BaseTableHandler<ItemUnitOfMeasure> {
  @override
  String get tableName => "item_unit_of_measure";

  @override
  ItemUnitOfMeasure fromMap(Map<String, dynamic> map) => ItemUnitOfMeasureExtension.fromMap(map);

  @override
  String extractKey(ItemUnitOfMeasure record) => record.id;

  @override
  Type get type => ItemUnitOfMeasure;
}
