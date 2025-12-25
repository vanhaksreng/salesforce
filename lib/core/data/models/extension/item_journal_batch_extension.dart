import 'package:salesforce/realm/scheme/item_schemas.dart';

extension ItemJournalBatchExtension on ItemJournalBatch {
  static ItemJournalBatch fromMap(Map<String, dynamic> item) {
    return ItemJournalBatch(
      item['id'] as String? ?? "",
      code: item['code'] as String?,
      description: item['description'] as String?,
      description2: item['description_2'] as String?,
      noSeriesCode: item['no_series_code'] as String?,
      reasonCode: item['reason_code'] as String?,
      balAccountType: item['bal_account_type'] as String?,
      inactived: item['inactived'] as String?,
    );
  }
}
