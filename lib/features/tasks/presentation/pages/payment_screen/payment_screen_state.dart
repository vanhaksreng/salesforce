import 'package:salesforce/realm/scheme/schemas.dart';

class PaymentScreenState {
  final bool isLoading;
  final String? error;
  final String? codePayment;
  final List<PaymentMethod> paymentMethods;

  const PaymentScreenState({this.isLoading = false, this.error, this.codePayment = "", this.paymentMethods = const []});

  PaymentScreenState copyWith({
    bool? isLoading,
    String? error,
    String? codePayment,
    List<PaymentMethod>? paymentMethods,
  }) {
    return PaymentScreenState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      codePayment: codePayment ?? this.codePayment,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}
