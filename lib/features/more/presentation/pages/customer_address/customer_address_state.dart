import 'package:salesforce/realm/scheme/schemas.dart';

class CustomerAddressState {
  final bool? loading;
  final List<CustomerAddress> cusAddresss;
  final CustomerAddress? address;

  CustomerAddressState({this.loading, this.cusAddresss = const [], this.address});

  CustomerAddressState copyWith({bool? loading, List<CustomerAddress>? cusAddresss, CustomerAddress? address}) {
    return CustomerAddressState(
      loading: loading ?? this.loading,
      cusAddresss: cusAddresss ?? this.cusAddresss,
      address: address ?? this.address,
    );
  }
}
