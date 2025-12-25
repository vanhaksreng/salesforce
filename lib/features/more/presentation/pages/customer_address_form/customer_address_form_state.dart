import 'package:salesforce/realm/scheme/schemas.dart';

class CustomerAddressFormState {
  final bool isLoading;
  final String? error;
  final String fullAddress;
  final CustomerAddress? cusAddress;

  const CustomerAddressFormState({this.isLoading = false, this.error, this.fullAddress = "", this.cusAddress});

  CustomerAddressFormState copyWith({
    bool? isLoading,
    String? error,
    String? fullAddress,
    CustomerAddress? cusAddress,
  }) {
    return CustomerAddressFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      fullAddress: fullAddress ?? this.fullAddress,
      cusAddress: cusAddress ?? this.cusAddress,
    );
  }
}
