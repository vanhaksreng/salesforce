import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/item_journal_batch_extension.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';

class ItemJournalBatchHandler extends BaseTableHandler<ItemJournalBatch> {
  @override
  String get tableName => "item_journal_batch";

  @override
  ItemJournalBatch fromMap(Map<String, dynamic> map) => ItemJournalBatchExtension.fromMap(map);

  @override
  String extractKey(ItemJournalBatch record) => record.id;

  @override
  Type get type => ItemJournalBatch;
}
