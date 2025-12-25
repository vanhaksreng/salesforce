import 'package:salesforce/realm/scheme/sales_schemas.dart';

class ItemWorksheetResponse {
  final List<ItemStockRequestWorkSheet> records;
  final String headerSatatus;

  const ItemWorksheetResponse({required this.records, required this.headerSatatus});
}
