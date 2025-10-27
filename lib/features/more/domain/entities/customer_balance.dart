import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class CustomerBalance {
  final List<CashReceiptJournals> cashReceiptJournals;
  final List<CustomerLedgerEntry> cusLegerEntries;

  CustomerBalance({
    required this.cashReceiptJournals,
    required this.cusLegerEntries,
  });

  // @override
  // String toString() => 'SaleDetail(header: $header, lines: $lines)';
}
