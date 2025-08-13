import 'package:salesforce/realm/scheme/schemas.dart';

class CustomerAddressState {
  final bool isLoading;
  final List<CustomerAddress> records;

  const CustomerAddressState({this.isLoading = false, this.records = const []});

  CustomerAddressState copyWith({bool? isLoading, List<CustomerAddress>? records}) {
    return CustomerAddressState(isLoading: isLoading ?? this.isLoading, records: records ?? this.records);
  }
}
