import 'package:salesforce/realm/scheme/schemas.dart';

class PaymentTermState {
  final bool isLoading;
  final List<PaymentTerm> records;

  const PaymentTermState({this.isLoading = false, this.records = const []});

  PaymentTermState copyWith({bool? isLoading, List<PaymentTerm>? records}) {
    return PaymentTermState(isLoading: isLoading ?? this.isLoading, records: records ?? this.records);
  }
}
