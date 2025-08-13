import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';

class CheckinState {
  final bool isLoading;
  final LatLng? latLng;
  final SalespersonSchedule? schedule;
  final String? checkInWithPhoto;
  final String? checkOutWithPhoto;

  const CheckinState({
    this.isLoading = false,
    this.latLng,
    this.schedule,
    this.checkInWithPhoto,
    this.checkOutWithPhoto,
  });

  CheckinState copyWith({
    bool? isLoading,
    LatLng? latLng,
    SalespersonSchedule? schedule,
    String? checkInWithPhoto,
    String? checkOutWithPhoto,
  }) {
    return CheckinState(
      isLoading: isLoading ?? this.isLoading,
      latLng: latLng ?? this.latLng,
      schedule: schedule ?? this.schedule,
      checkInWithPhoto: checkInWithPhoto ?? this.checkInWithPhoto,
      checkOutWithPhoto: checkOutWithPhoto ?? this.checkOutWithPhoto,
    );
  }
}
