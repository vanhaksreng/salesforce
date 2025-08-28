import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class CustomersState {
  final bool isLoading;
  final String? error;
  final List<Customer> records;
  final Customer? customer;
  final bool isValidation;
  final String messageCode;
  final LatLng? latLng;
  final double distanceValue;
  final bool isSortdistance;

  const CustomersState({
    this.isLoading = false,
    this.error,
    this.records = const [],
    this.customer,
    this.isValidation = false,
    this.isSortdistance = false,
    this.messageCode = "",
    this.latLng,
    this.distanceValue = 0,
  });

  CustomersState copyWith({
    bool? isLoading,
    String? error,
    List<Customer>? records,
    Customer? customer,
    bool? isValidation,
    String? messageCode,
    LatLng? latLng,
    double? distanceValue,
    bool? isSortdistance,
  }) {
    return CustomersState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      records: records ?? this.records,
      customer: customer ?? this.customer,
      isValidation: isValidation ?? this.isValidation,
      messageCode: messageCode ?? this.messageCode,
      latLng: latLng ?? this.latLng,
      distanceValue: distanceValue ?? this.distanceValue,
      isSortdistance: isSortdistance ?? this.isSortdistance,
    );
  }
}
