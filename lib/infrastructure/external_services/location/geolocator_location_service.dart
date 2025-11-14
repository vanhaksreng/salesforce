import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/infrastructure/external_services/location/i_location_service.dart';
import 'package:salesforce/infrastructure/external_services/location/location_permission_status.dart';

class GeolocatorLocationService implements ILocationService {
  static const int _defaultDistanceFilter = 5;
  static const double _maxAcceptableAccuracy = 10.0;
  static const LocationAccuracy _defaultAccuracy = LocationAccuracy.best;
  static const Duration _locationTimeout = Duration(seconds: 30);

  StreamSubscription<Position>? _subscription;
  bool _isTracking = false;

  bool get isTracking => _isTracking;
  bool get hasActiveSubscription => _subscription != null;

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      Logger.log("Error checking location service status: $e");
      return false;
    }
  }

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return _mapGeolocatorPermission(permission);
    } catch (e) {
      Logger.log("Error checking location permission: $e");
      return LocationPermissionStatus.notDetermined;
    }
  }

  @override
  Future<LocationPermissionStatus> requestPermission(
    BuildContext context,
  ) async {
    try {
      // Check and request location service first
      await _ensureLocationServiceEnabled(context);

      // Then request permission
      final permission = await Geolocator.requestPermission();
      final status = _mapGeolocatorPermission(permission);

      Logger.log("Location permission granted: ${status.name}");
      return status;
    } catch (e) {
      Logger.log("Error requesting location permission: $e");
      rethrow;
    }
  }

  @override
  Future<Position> getCurrentLocation({
    required BuildContext context,
    LocationSettings? customSettings,
  }) async {
    try {
      await _ensureLocationServiceEnabled(context);
      await _ensureLocationPermission();

      final locationSettings = customSettings ?? _getLocationSettings();

      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      ).timeout(_locationTimeout);

      return position;
    } on TimeoutException {
      throw GeneralException(
        "Location request timed out after ${_locationTimeout.inSeconds} seconds",
      );
    } catch (e) {
      Logger.log("Error getting current location: $e");
      rethrow;
    }
  }

  @override
  Stream<Position> getPositionStream({
    LocationSettings? locationSettings,
    double maxAcceptableAccuracy = _maxAcceptableAccuracy,
  }) {
    locationSettings ??= _getLocationSettings();

    var stream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );

    if (maxAcceptableAccuracy > 0) {
      stream = stream.where(
        (position) => position.accuracy <= maxAcceptableAccuracy,
      );
    }

    return stream.handleError((error) {
      Logger.log("Position stream error: $error");
    });
  }

  @override
  StreamSubscription<Position> startContinuousLocationTracking({
    required void Function(Position) onData,
    int distanceFilter = _defaultDistanceFilter,
    void Function(Object error)? onError,
    void Function()? onDone,
    bool cancelOnError = false,
    double maxAcceptableAccuracy = _maxAcceptableAccuracy,
  }) {
    // Stop any existing tracking
    if (_isTracking) {
      stopTracking();
    }

    try {
      final locationSettings = _getLocationSettings(
        distanceFilter: distanceFilter,
      );

      // Use the existing getPositionStream method to avoid duplication
      final stream = getPositionStream(
        locationSettings: locationSettings,
        maxAcceptableAccuracy: maxAcceptableAccuracy,
      );

      _subscription = stream.listen(
        (position) {
          onData(position);
        },
        onError: (error) {
          Logger.log("Location tracking error: $error");
          onError?.call(error);
        },
        onDone: () {
          Logger.log("Location tracking completed");
          _isTracking = false;
          onDone?.call();
        },
        cancelOnError: cancelOnError,
      );

      _isTracking = true;
      Logger.log(
        "Continuous location tracking started with ${distanceFilter}m filter",
      );

      return _subscription!;
    } catch (e) {
      Logger.log("Error starting location tracking: $e");
      rethrow;
    }
  }

  void stopTracking() {
    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
      _isTracking = false;
      Logger.log("Location tracking stopped");
    }
  }

  @override
  double getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    try {
      return Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );
    } catch (e) {
      Logger.log("Error calculating distance: $e");
      return 0.0;
    }
  }

  /// Additional utility methods

  Future<double> getDistanceFromCurrentLocation(
    BuildContext context,
    double targetLatitude,
    double targetLongitude,
  ) async {
    try {
      final currentPosition = await getCurrentLocation(context: context);
      return getDistanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        targetLatitude,
        targetLongitude,
      );
    } catch (e) {
      Logger.log("Error getting distance from current location: $e");
      rethrow;
    }
  }

  Future<double> getBearingTo(
    BuildContext context,
    double targetLatitude,
    double targetLongitude,
  ) async {
    try {
      final currentPosition = await getCurrentLocation(context: context);
      return Geolocator.bearingBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        targetLatitude,
        targetLongitude,
      );
    } catch (e) {
      Logger.log("Error calculating bearing: $e");
      rethrow;
    }
  }

  /// Disposes of resources and stops tracking
  void dispose() {
    stopTracking();
    Logger.log("GeolocatorLocationService disposed");
  }

  static bool _isAlertCurrentlyShowing = false;

  // (Assuming this function is part of a class with the static flag)
  // static bool _isAlertCurrentlyShowing = false;

  Future<void> _ensureLocationServiceEnabled(BuildContext context) async {
    // 1. Check current status
    bool serviceEnabled = await isLocationServiceEnabled();

    if (!serviceEnabled) {
      Logger.log("Location service disabled, showing alert to open settings");

      // Prevent concurrent dialogs
      if (_isAlertCurrentlyShowing) {
        throw GeneralException(
          "Location services check is already in progress.",
        );
      }

      _isAlertCurrentlyShowing = true; // Lock the function

      bool? didConfirm;
      if (!context.mounted) return;
      try {
        didConfirm = await Helpers.showDialogAction(
          context,
          labelAction: "Location Services Required",
          subtitle:
              "Location services are currently disabled. Please enable them in your device settings to use this feature.",
          canCancel: true,
          cancelText: "No, Cancel",
          confirmText: "Yes, Open setting",

          confirm: () async {
            Navigator.pop(context);
            await Geolocator.openLocationSettings();
          },
        );
      } finally {
        _isAlertCurrentlyShowing = false;
      }

      if (didConfirm == true) {
        await Geolocator.openLocationSettings();

        await Future.delayed(const Duration(milliseconds: 500));
        serviceEnabled = await isLocationServiceEnabled();
      }

      if (!serviceEnabled) {
        throw GeneralException(
          "Location services must be enabled to use this feature",
        );
      }
    }
  }

  Future<void> _ensureLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw GeneralException(
          'Location permission is required for this feature',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw GeneralException(
        'Location permission has been permanently denied. '
        'Please enable it in your device settings to use this feature.',
      );
    }
  }

  LocationPermissionStatus _mapGeolocatorPermission(
    LocationPermission permission,
  ) {
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

  LocationSettings _getLocationSettings({
    int distanceFilter = _defaultDistanceFilter,
    LocationAccuracy accuracy = _defaultAccuracy,
  }) {
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        activityType: ActivityType.other,
      );
    } else if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        forceLocationManager: false,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: _getForegroundNotificationConfig(),
      );
    }

    // Fallback for other platforms
    return LocationSettings(accuracy: accuracy, distanceFilter: distanceFilter);
  }

  ForegroundNotificationConfig _getForegroundNotificationConfig() {
    return const ForegroundNotificationConfig(
      notificationTitle: 'Location Tracking Active',
      notificationText: 'Your location is being tracked for work purposes',
      notificationIcon: AndroidResource(name: "@mipmap/ic_launcher"),
      // color: Color.fromARGB(255, 64, 153, 255),
      enableWakeLock: true,
      setOngoing: true,
    );
  }
}
