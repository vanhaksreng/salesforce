import 'package:salesforce/realm/scheme/sales_schemas.dart';

class SaleDetail {
  final PosSalesHeader header;
  final List<PosSalesLine> lines;

  SaleDetail({required this.header, required this.lines});

  @override
  String toString() => 'SaleDetail(header: $header, lines: $lines)';
}
