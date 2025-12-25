import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/item_promotion_scheme_extension.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';

class ItemPromotionSchemeHandler extends BaseTableHandler<ItemPromotionScheme> {
  @override
  String get tableName => "item_promotion_header";

  @override
  ItemPromotionScheme fromMap(Map<String, dynamic> map) => ItemPromotionSchemeExtension.fromMap(map);

  @override
  String extractKey(ItemPromotionScheme record) => record.code;

  @override
  Type get type => ItemPromotionScheme;
}
