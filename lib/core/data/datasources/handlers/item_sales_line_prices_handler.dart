import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/item_sales_line_prices_extension.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';

class ItemSalesLinePricesHandler extends BaseTableHandler<ItemSalesLinePrices> {
  @override
  String get tableName => "item_sales_line_prices";

  @override
  ItemSalesLinePrices fromMap(Map<String, dynamic> map) => ItemSalesLinePricesExtension.fromMap(map);

  @override
  String extractKey(ItemSalesLinePrices record) => record.id;

  @override
  Type get type => ItemSalesLinePrices;
}
