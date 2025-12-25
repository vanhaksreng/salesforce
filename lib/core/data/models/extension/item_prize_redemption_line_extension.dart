import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';

extension ItemPrizeRedemptionLineExtension on ItemPrizeRedemptionLine {
  static ItemPrizeRedemptionLine fromMap(Map<String, dynamic> item) {
    return ItemPrizeRedemptionLine(
      Helpers.toInt(item['id']),
      lineNo: Helpers.toInt(item['line_no']),
      promotionNo: item['promotion_no'] as String?,
      itemNo: item['item_no'] as String?,
      variantCode: item['variant_code'] as String?,
      redemptionType: item['redemption_type'] as String?,
      description: item['description'] as String?,
      description2: item['description_2'] as String?,
      unitOfMeasureCode: item['unit_of_measure_code'] as String?,
      qtyPerUnitOfMeasure: Helpers.formatNumberDb(item['qty_per_unit_of_measure'], option: FormatType.quantity),
      quantity: Helpers.formatNumberDb(item['quantity'], option: FormatType.quantity),
      unitPrice: Helpers.formatNumberDb(item['unit_price'], option: FormatType.price),
      discountPercentage: Helpers.formatNumberDb(item['discount_percentage'], option: FormatType.percentage),
      discountAmount: Helpers.formatNumberDb(item['discount_amount'], option: FormatType.amount),
      amount: Helpers.formatNumberDb(item['amount'], option: FormatType.amount),
      isSync: item['is_sync'] as String? ?? "Yes",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'line_no': lineNo,
      'promotion_no': promotionNo,
      'item_no': itemNo,
      'variant_code': variantCode,
      'redemption_type': redemptionType,
      'description': description,
      'description_2': description2,
      'unit_of_measure_code': unitOfMeasureCode,
      'qty_per_unit_of_measure': qtyPerUnitOfMeasure,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount_percentage': discountPercentage,
      'discount_amount': discountAmount,
      'amount': amount,
      'is_sync': isSync,
    };
  }
}
