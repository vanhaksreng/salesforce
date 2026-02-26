import 'dart:async';

import 'package:flutter/material.dart';
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

  Future<LocationPermissionStatus> checkPermission();
  Future<bool> hasPermission();
  // Future<void> ensureLocationPermission(BuildContext context);
  Future<LocationPermissionStatus> requestPermission(BuildContext context);
  Future<Position> getCurrentLocation({required BuildContext context});
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
