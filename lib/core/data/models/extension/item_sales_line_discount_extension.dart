import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';

extension ItemSalesLineDiscountExtension on ItemSalesLineDiscount {
  static ItemSalesLineDiscount fromMap(Map<String, dynamic> item) {
    return ItemSalesLineDiscount(
      item['id'] as String? ?? "",
      type: item['type'] as String?,
      code: item['code'] as String?,
      saleType: item['sale_type'] as String?,
      salesCode: item['sales_code'] as String?,
      variantCode: item['variant_code'] as String?,
      uomCode: item['uom_code'] as String?,
      minimumAmount: Helpers.formatNumberDb(item['minimum_amount'] ?? 0),
      minimumQuantity: Helpers.formatNumberDb(item['minimum_quantity'] ?? 0, option: FormatType.quantity),
      lineDiscountPercent: Helpers.formatNumberDb(item['line_discount_percent'] ?? 0, option: FormatType.percentage),
      discAmount: Helpers.formatNumberDb(item['disc_amount'] ?? 0),
      startingDate: item['starting_date'] as String?,
      endingDate: item['ending_date'] as String?,
    );
  }
}
