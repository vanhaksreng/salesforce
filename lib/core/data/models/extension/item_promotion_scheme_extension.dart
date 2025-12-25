import 'package:salesforce/realm/scheme/item_schemas.dart';

extension ItemPromotionSchemeExtension on ItemPromotionScheme {
  static ItemPromotionScheme fromMap(Map<String, dynamic> item) {
    return ItemPromotionScheme(
      item['code'] as String? ?? "",
      description: item['description'] as String?,
      description2: item['description_2'] as String?,
      itemsNos: item['items_nos'] as String?,
      inactived: item['inactived'] as String?,
    );
  }
}
