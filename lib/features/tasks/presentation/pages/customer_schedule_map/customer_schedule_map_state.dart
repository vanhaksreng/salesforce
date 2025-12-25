import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';

class CustomerScheduleMapState {
  final bool isLoading;
  final List<SalespersonSchedule>? schedules;
  final Set<Marker> markers;
  final CameraPosition? kGooglePostition;
  final GoogleMapController? mapController;
  final List<Customer> customers;

  const CustomerScheduleMapState({
    this.isLoading = false,
    this.schedules,
    this.markers = const {},
    this.kGooglePostition,
    this.mapController,
    this.customers = const [],
  });

  CustomerScheduleMapState copyWith({
    bool? isLoading,
    List<SalespersonSchedule>? schedules,
    Set<Marker>? markers,
    CameraPosition? kGooglePostition,
    GoogleMapController? mapController,
    List<Customer>? customers,
  }) {
    return CustomerScheduleMapState(
      isLoading: isLoading ?? this.isLoading,
      schedules: schedules ?? this.schedules,
      markers: markers ?? this.markers,
      kGooglePostition: kGooglePostition ?? this.kGooglePostition,
      mapController: mapController ?? this.mapController,
      customers: customers ?? this.customers,
    );
  }
}
