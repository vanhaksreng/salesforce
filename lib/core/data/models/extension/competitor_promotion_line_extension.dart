import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

extension CompetitorPromotionLineExtension on CompetitorPromotionLine {
  static CompetitorPromotionLine fromMap(Map<String, dynamic> item) {
    return CompetitorPromotionLine(
      item['id'] as String? ?? '',
      lineNo: item['line_no'] as String?,
      promotionNo: item['promotion_no'] as String?,
      itemNo: item['item_no'] as String?,
      variantCode: item['variant_code'] as String?,
      description: item['description'] as String?,
      description2: item['description_2'] as String?,
      promotionType: item['promotion_type'] as String?,
      unitOfMeasureCode: item['unit_of_measure_code'] as String?,
      qtyPerUnitOfMeasure: Helpers.formatNumberDb(item['qty_per_unit_of_measure']),
      quantity: Helpers.formatNumberDb(item['quantity']),
      unitPrice: Helpers.formatNumberDb(['unit_price'], option: FormatType.price),
      discountPercentage: Helpers.formatNumberDb(['discount_percentage'], option: FormatType.percentage),
      discountAmount: Helpers.formatNumberDb(['discount_amount'], option: FormatType.amount),
      amount: Helpers.formatNumberDb(['amount'], option: FormatType.amount),
    );
  }
}
