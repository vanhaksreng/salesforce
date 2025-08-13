import 'package:salesforce/realm/scheme/sales_schemas.dart';

class RecordSaleHeader {
  final List<SalesHeader>? saleHeaders;
  final int? currentPage;
  final int? lastPage;

  RecordSaleHeader({this.saleHeaders, this.currentPage, this.lastPage});
}
