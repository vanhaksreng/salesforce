import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';

extension ApplicationSetupExtension on ApplicationSetup {
  static ApplicationSetup fromMap(Map<String, dynamic> json) {
    return ApplicationSetup(
      Helpers.toStrings(json["id"]),
      quantityDecimal: Helpers.toInt(json["quantity_decimal"]),
      costDecimal: Helpers.toInt(json["cost_decimal"]),
      priceDecimal: Helpers.toInt(json["price_decimal"]),
      amountDecimal: Helpers.toInt(json["amount_decimal"]),
      itemQtyFormat: Helpers.toInt(json["item_qty_format"]),
      localCurrencyCode: json["local_currency_code"],
      decimalZero: json["decimal_zero"],
      ctrlItemTracking: json["ctrl_item_tracking"] ?? kStatusNo,
    );
  }
}
