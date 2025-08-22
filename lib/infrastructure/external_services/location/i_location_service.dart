import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:salesforce/infrastructure/external_services/location/location_permission_status.dart';

abstract class ILocationService {
  Future<bool> isLocationServiceEnabled();
  double getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  );

  /// Checks the current location permission status.
  Future<LocationPermissionStatus> checkPermission();

  /// Requests location permissions from the user.
  /// Returns the new permission status.
  Future<LocationPermissionStatus> requestPermission();

  /// Gets the current position of the device.
  /// Throws an exception if permissions are not granted or service is disabled.
  Future<Position> getCurrentLocation();

  /// Provides a stream of location updates.
  /// Not implemented in this example but shows extensibility.
  Stream<Position> getPositionStream({
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    ),
  });

  StreamSubscription<Position> startContinuousLocationTracking({
    required void Function(Position) onData,
    int distanceFilter = 10,
  });
}
