import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

extension CurrencyExchangeRateExtension on CurrencyExchangeRate {
  static CurrencyExchangeRate fromMap(Map<String, dynamic> item) {
    return CurrencyExchangeRate(
      item['id'] as String? ?? "",
      startingDate: item['starting_date'] ?? "",
      currencyCode: item['currency_code'] as String? ?? "",
      exchangeAmount: Helpers.toDouble(item['exchange_amount']),
      exchangeRate: Helpers.toDouble(item['exchange_rate']),
      currencyFactor: Helpers.toDouble(item['currency_factor']),
    );
  }
}
