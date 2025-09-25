import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/features/tasks/domain/entities/sale_person_gps_model.dart';

class SalesPersonMapState {
  final bool isLoading;
  final String? error;
  // final List<SalePersonGpsModel> salePersonGps;
  final Set<Marker> markers;
  final CameraPosition? kGooglePostition;
  final GoogleMapController? mapController;
  final SalePersonGpsModel? salePerson;

  const SalesPersonMapState({
    this.isLoading = false,
    this.error,
    // this.salePersonGps = const [],
    this.markers = const {},
    this.kGooglePostition,
    this.mapController,
    this.salePerson,
  });

  SalesPersonMapState copyWith({
    bool? isLoading,
    String? error,
    // List<SalePersonGpsModel>? salePersonGps,
    Set<Marker>? markers,
    CameraPosition? kGooglePostition,
    GoogleMapController? mapController,
    SalePersonGpsModel? salePerson,
  }) {
    return SalesPersonMapState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      // salePersonGps: salePersonGps ?? this.salePersonGps,
      markers: markers ?? this.markers,
      kGooglePostition: kGooglePostition ?? this.kGooglePostition,
      mapController: mapController ?? this.mapController,
      salePerson: salePerson ?? this.salePerson,
    );
  }
}
