import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class CollectionsState {
  final bool isLoading;
  final String? error;

  final List<CustomerLedgerEntry> cusLedgerEntry;
  final List<CashReceiptJournals> casReJounals;
  final List<PaymentMethod> paymentMethods;

  const CollectionsState({
    this.isLoading = false,
    this.error,

    this.casReJounals = const [],
    this.cusLedgerEntry = const [],
    this.paymentMethods = const [],
  });

  CollectionsState copyWith({
    bool? isLoading,
    String? error,
    List<CustomerLedgerEntry>? cusLedgerEntry,
    List<CashReceiptJournals>? casReJounals,
    List<PaymentMethod>? paymentMethods,
    double? totalReceiveAmt,
  }) {
    return CollectionsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      casReJounals: casReJounals ?? this.casReJounals,
      cusLedgerEntry: cusLedgerEntry ?? this.cusLedgerEntry,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}
