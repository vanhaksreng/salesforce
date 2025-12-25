import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

extension PaymentTermExtension on PaymentTerm {
  static PaymentTerm fromMap(Map<String, dynamic> item) {
    return PaymentTerm(
      item['code'] as String? ?? "",
      description: item['description'] as String?,
      description2: item['description_2'] as String?,
      dueDateCalculation: item['due_date_calculation'] ?? "",
      discountDateCalculation: item['discount_date_calculation'] ?? "",
      discountPercentage: Helpers.formatNumberDb(item['discount_percentage'] ?? 0, option: FormatType.percentage),
      discountAmount: Helpers.formatNumberDb(item['discount_amount'] ?? 0, option: FormatType.amount),
      inactived: item['inactived'] ?? "",
    );
  }
}
