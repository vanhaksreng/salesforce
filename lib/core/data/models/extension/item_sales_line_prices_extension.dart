import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';

extension ItemSalesLinePricesExtension on ItemSalesLinePrices {
  static ItemSalesLinePrices fromMap(Map<String, dynamic> item) {
    return ItemSalesLinePrices(
      item['id'] as String? ?? "",
      salesType: item['sales_type'] as String? ?? "",
      salesCode: item['sales_code'] as String? ?? "",
      itemNo: item['item_no'] as String? ?? "",
      variantCode: item['variant_code'] as String? ?? "",
      uomCode: item['uom_code'] as String? ?? "",
      minimumQuantity: Helpers.formatNumberDb(item['minimum_quantity'], option: FormatType.quantity),
      unitPrice: Helpers.formatNumberDb(item['unit_price'], option: FormatType.price),
      discountPercentage: Helpers.formatNumberDb(item['discount_percentage'], option: FormatType.percentage),
      discountAmount: Helpers.formatNumberDb(item['discount_amount'], option: FormatType.amount),
      startingDate: item['starting_date'] as String? ?? "",
      endingDate: item['ending_date'] as String? ?? "",
    );
  }
}
