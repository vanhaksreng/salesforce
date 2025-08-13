import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class DetailCollectionsState {
  final bool isLoading;
  final List<PaymentMethod> paymentMethods;
  final List<CashReceiptJournals> cashReceiptJournals;
  final double totalReceiveAmt;

  const DetailCollectionsState({
    this.isLoading = false,
    this.totalReceiveAmt = 0,
    this.cashReceiptJournals = const [],
    this.paymentMethods = const [],
  });

  DetailCollectionsState copyWith({
    bool? isLoading,
    CustomerLedgerEntry? cusLedgerEntry,
    double? totalReceiveAmt,
    List<CashReceiptJournals>? cashReceiptJournals,
    List<PaymentMethod>? paymentMethods,
  }) {
    return DetailCollectionsState(
      isLoading: isLoading ?? this.isLoading,
      totalReceiveAmt: totalReceiveAmt ?? this.totalReceiveAmt,
      cashReceiptJournals: cashReceiptJournals ?? this.cashReceiptJournals,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}
