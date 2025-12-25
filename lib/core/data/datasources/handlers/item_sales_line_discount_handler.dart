import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/item_sales_line_discount_extension.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';

class ItemSalesLineDiscountHandler extends BaseTableHandler<ItemSalesLineDiscount> {
  @override
  String get tableName => "item_sales_line_discount";

  @override
  ItemSalesLineDiscount fromMap(Map<String, dynamic> map) => ItemSalesLineDiscountExtension.fromMap(map);

  @override
  String extractKey(ItemSalesLineDiscount record) => record.id;

  @override
  Type get type => ItemSalesLineDiscount;
}
