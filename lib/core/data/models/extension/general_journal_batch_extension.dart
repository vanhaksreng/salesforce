import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

extension GeneralJournalBatchExtension on GeneralJournalBatch {
  static GeneralJournalBatch fromMap(Map<String, dynamic> item) {
    return GeneralJournalBatch(
      Helpers.toStrings(item['id'] ?? ""),
      code: item['code'],
      description: Helpers.toStrings(item['description']),
      description2: Helpers.toStrings(item['description_2'] ?? ""),
      type: Helpers.toStrings(item['type'] ?? ""),
      noSeriesCode: Helpers.toStrings(item['no_series_code'] ?? ""),
      balAccountType: Helpers.toStrings(item['bal_account_type'] ?? ""),
      balAccountNo: Helpers.toStrings(item['bal_account_no'] ?? ""),
      inactived: item['inactived'] ?? kStatusNo,
    );
  }
}
