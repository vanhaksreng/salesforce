import 'package:salesforce/realm/scheme/sales_schemas.dart';

class RecordSaleHeader {
  final List<SalesHeader> saleHeaders;
  final int? currentPage;
  final int? lastPage;

  RecordSaleHeader({
    this.saleHeaders = const [],
    this.currentPage,
    this.lastPage,
  });

  factory RecordSaleHeader.fromJson(Map<String, dynamic> json) {
    return RecordSaleHeader(
      saleHeaders:
          (json['saleHeaders'] as List<dynamic>?)
              ?.map((e) => SalesHeader(e))
              .toList() ??
          [],
      currentPage: json['currentPage'] as int?,
      lastPage: json['lastPage'] as int?,
    );
  }
}
