import 'package:salesforce/realm/scheme/sales_schemas.dart';

class SaleDetailReport {
  final PosSalesHeader header;
  final List<PosSalesLine> lines;

  SaleDetailReport({required this.header, required this.lines});
}
