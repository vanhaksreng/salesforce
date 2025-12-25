import 'package:salesforce/realm/scheme/schemas.dart';

class CustomerAddressState {
  final bool isLoading;
  final List<CustomerAddress> records;
  final String addressCode;

  const CustomerAddressState({
    this.isLoading = false,
    this.records = const [],
    this.addressCode = "",
  });

  CustomerAddressState copyWith({
    bool? isLoading,
    List<CustomerAddress>? records,
    String? addressCode,
  }) {
    return CustomerAddressState(
      isLoading: isLoading ?? this.isLoading,
      records: records ?? this.records,
      addressCode: addressCode ?? this.addressCode,
    );
  }
}
