import 'package:salesforce/realm/scheme/schemas.dart';

extension CurrencyExtension on Currency {
  static Currency fromMap(Map<String, dynamic> item) {
    return Currency(
      item['code'] as String? ?? "",
      description: item['description'] as String? ?? "",
      description2: item['description_2'] as String? ?? "",
      symbol: item['symbol'] as String? ?? "",
      inactived: item['inactived'] as String? ?? "",
    );
  }
}
