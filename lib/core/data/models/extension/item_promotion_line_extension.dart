import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';

extension ItemPromotionLineExtension on ItemPromotionLine {
  static ItemPromotionLine fromMap(Map<String, dynamic> json) {
    return ItemPromotionLine(
      Helpers.toStrings(json['id']),
      type: Helpers.toStrings(json['type']),
      lineNo: Helpers.toInt(json['line_no'] as String? ?? ""),
      itemNo: Helpers.toStrings(json['item_no']),
      description: json['description'] as String? ?? '',
      description2: json['description_2'] as String? ?? '',
      promotionNo: json['promotion_no'],
      promotionType: json['promotion_type'],
      unitOfMeasureCode: json['unit_of_measure_code'],
      qtyPerUnitOfMeasure: Helpers.toDouble(json['qty_per_unit_of_measure']),
      quantity: Helpers.toDouble(json['quantity']),
      maximumOfferQuantity: Helpers.toDouble(json['maximum_offer_quantity']),
      discountPercentage: Helpers.toDouble(json['discount_percentage']),
      discountAmount: Helpers.toDouble(json['discount_amount']),
      amount: Helpers.toDouble(json['amount']),
      unitPrice: Helpers.toDouble(json['unit_price']),
      sellingPriceOption: json['selling_price_option'],
    );
  }
}
