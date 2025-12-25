import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomerMapState {
  final bool isLoading;
  final String? error;
  final CameraPosition? position;
  final LatLng? currentLatLng;

  const CustomerMapState({
    this.isLoading = false,
    this.error,
    this.position,
    this.currentLatLng,
  });

  CustomerMapState copyWith({
    bool? isLoading,
    String? error,
    CameraPosition? position,
    LatLng? currentLatLng,
  }) {
    return CustomerMapState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      position: position ?? this.position,
      currentLatLng: currentLatLng ?? this.currentLatLng,
    );
  }
}
