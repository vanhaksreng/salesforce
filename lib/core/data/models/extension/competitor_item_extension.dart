import 'package:salesforce/realm/scheme/item_schemas.dart';

extension CompetitorItemExtension on CompetitorItem {
  static CompetitorItem fromMap(Map<String, dynamic> item) {
    return CompetitorItem(
      item['no'] as String? ?? "",
      no2: item['no2'] as String? ?? "",
      identifierCode: item['identifier_code'] as String? ?? "",
      description: item['description'] as String? ?? "",
      description2: item['description_2'] as String? ?? "",
      itemBrandCode: item['item_brand_code'] as String? ?? "",
      itemGroupCode: item['item_group_code'] as String? ?? "",
      itemCategoryCode: item['item_category_code'] as String? ?? "",
      businessUnitCode: item['business_unit_code'] as String? ?? "",
      unitPrice: item['unit_price'] as String? ?? "",
      vendorNo: item['vendor_no'] as String? ?? "",
      competitorNo: item['competitor_no'] as String? ?? "",
      salesUomCode: item['sales_uom_code'] as String? ?? "",
      purchaseUomCode: item['purchase_uom_code'] as String? ?? "",
      picture: item['picture'] as String? ?? "",
      avatar32: item['avatar_32'] as String? ?? "",
      avatar128: item['avatar_128'] as String? ?? "",
      inactived: item['inactived'] as String? ?? "",
      remark: item['remark'] as String? ?? "",
    );
  }
}
