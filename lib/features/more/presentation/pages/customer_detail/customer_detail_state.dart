import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class CustomerDetailState {
  final bool? loading;
  final String? error;
  final Customer? record;
  final CameraPosition? initialCameraPosition;
  final Marker? currentLocationMarker;
  final bool? locationLoaded;
  final int tabIndex;
  final List<CustomerAddress>? recordAddresses;
  final double latitude;
  final double longtitude;

  CustomerDetailState({
    this.loading,
    this.error,
    this.record,
    this.initialCameraPosition,
    this.currentLocationMarker,
    this.locationLoaded,
    this.tabIndex = 0,
    this.recordAddresses,
    this.latitude = 0.0,
    this.longtitude = 0.0,
  });

  CustomerDetailState copyWith({
    bool? loading,
    String? error,
    Customer? record,
    CameraPosition? initialCameraPosition,
    Marker? currentLocationMarker,
    bool? locationLoaded,
    int? tabIndex,
    List<CustomerAddress>? recordAddresses,
    double? latitude,
    double? longtitude,
  }) {
    return CustomerDetailState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      record: record ?? this.record,
      initialCameraPosition: initialCameraPosition ?? this.initialCameraPosition,
      currentLocationMarker: currentLocationMarker ?? this.currentLocationMarker,
      locationLoaded: locationLoaded ?? this.locationLoaded,
      tabIndex: tabIndex ?? this.tabIndex,
      recordAddresses: recordAddresses ?? this.recordAddresses,
      latitude: latitude ?? this.latitude,
      longtitude: longtitude ?? this.longtitude,
    );
  }
}
