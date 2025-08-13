import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

extension VatPostingSetupExtension on VatPostingSetup {
  static VatPostingSetup fromMap(Map<String, dynamic> item) {
    return VatPostingSetup(
      Helpers.toStrings(item['id'] ?? ""),
      vatBusPostingGroup: item['vat_bus_posting_group'] as String?,
      vatProdPostingGroup: item['vat_prod_posting_group'] as String?,
      vatCalculationType: item['vat_calculation_type'] as String?,
      vatAmount: item['vat_amount'] as String?,
      inactived: item['inactived'] as String?,
    );
  }
}
