import 'package:salesforce/realm/scheme/item_schemas.dart';

extension ItemGroupExtension on ItemGroup {
  static ItemGroup fromMap(Map<String, dynamic> item) {
    return ItemGroup(
      item['code'] as String? ?? "",
      description: item['description'] as String? ?? "",
      description2: item['description_2'] as String? ?? "",
      itemBrandCode: item['item_brand_code'] as String? ?? "",
      itemCategoryCode: item['item_category_code'] as String? ?? "",
      picture: item['picture'] as String? ?? "",
      inactived: item['inactived'] as String? ?? "",
    );
  }
}
