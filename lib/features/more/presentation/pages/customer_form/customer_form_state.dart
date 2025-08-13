import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class CustomerFormState {
  final bool isLoading;
  final LatLng? latlng;
  final Customer? customer;
  final String fullAddress;

  const CustomerFormState({this.isLoading = false, this.latlng, this.customer, this.fullAddress = ""});

  CustomerFormState copyWith({bool? isLoading, LatLng? latlng, Customer? customer, String? fullAddress}) {
    return CustomerFormState(
      isLoading: isLoading ?? this.isLoading,
      latlng: latlng ?? this.latlng,
      customer: customer ?? this.customer,
      fullAddress: fullAddress ?? this.fullAddress,
    );
  }
}
