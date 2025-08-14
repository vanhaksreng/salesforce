import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/infrastructure/external_services/location/i_location_service.dart';
import 'package:salesforce/infrastructure/external_services/location/location_permission_status.dart';

class GeolocatorLocationService implements ILocationService {
  StreamSubscription<Position>? _subscription;

  /// Checks if location services are enabled on the device.
  @override
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Checks the current location permission status.
  @override
  Future<LocationPermissionStatus> checkPermission() async {
    final permission = await Geolocator.checkPermission();
    return _mapGeolocatorPermission(permission);
  }

  /// Requests location permissions from the user.
  @override
  Future<LocationPermissionStatus> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return _mapGeolocatorPermission(permission);
  }

  @override
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw GeneralException("Location services are disabled");
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw GeneralException('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw GeneralException('Location permissions are permanently denied. Please enable them in app settings.');
    }

    return await Geolocator.getCurrentPosition();
  }

  /// Provides a stream of location updates.
  /// Not fully implemented, but shows the method signature.
  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    locationSettings ??= _getLocationSettings();

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  @override
  StreamSubscription<Position> startContinuousLocationTracking({
    required void Function(Position) onLocationUpdate,
    int distanceFilter = 5, // Default distance filter in meters
  }) {
    final settings = _getLocationSettings(distanceFilter: distanceFilter);
    _subscription = Geolocator.getPositionStream(locationSettings: settings).listen(onLocationUpdate);

    return _subscription!;
  }

  void stopTracking() {
    _subscription?.cancel();
  }

  /// Helper to map Geolocator's [LocationPermission] to our custom [LocationPermissionStatus].
  LocationPermissionStatus _mapGeolocatorPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return LocationPermissionStatus.granted;
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.notDetermined;
    }
  }

  LocationSettings _getLocationSettings({int distanceFilter = 5}) {
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: distanceFilter,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    }

    return AndroidSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: distanceFilter,
      foregroundNotificationConfig: ForegroundNotificationConfig(
        notificationTitle: 'Location Tracking',
        notificationIcon: const AndroidResource(name: "@mipmap/ic_launcher"),
        notificationText: 'App is tracking location in background $distanceFilter',
        enableWakeLock: true,
      ),
    );
  }

  @override
  double getDistanceBetween(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
  }
}
