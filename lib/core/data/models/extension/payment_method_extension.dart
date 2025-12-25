import 'package:salesforce/realm/scheme/schemas.dart';

extension PaymentMethodExtension on PaymentMethod {
  static PaymentMethod fromMap(Map<String, dynamic> item) {
    return PaymentMethod(
      item['code'] as String? ?? "",
      code2: item['code2'] as String? ?? "",
      description: item['description'] as String?,
      description2: item['description2'] as String?,
      balanceAccountType: item['balance_account_type'] as String?,
      balanceAccountNo: item['balance_account_no'] as String?,
      appIcon: item['app_icon'] as String?,
      appIcon32: item['app_icon_32'] as String?,
      appIcon128: item['app_icon_128'] as String?,
      inactived: item['inactived'] as String?,
    );
  }
}
