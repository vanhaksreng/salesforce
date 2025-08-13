import 'dart:io';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/infrastructure/external_services/location/geolocator_location_service.dart';
import 'package:salesforce/infrastructure/gps/gps_service_impl.dart';
import 'package:salesforce/injection_container.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  final _location = GeolocatorLocationService();
  final appRepo = getIt<BaseAppRepository>();

  bool _isForegroundTracking = false;
  bool _isBackgroundTracking = false;

  void startForegroundTracking() {
    if (_isForegroundTracking) return;

    final GpsServiceImpl gpsService = GpsServiceImpl(appRepo);
    final auth = getAuth();

    _location.startContinuousLocationTracking(
      onLocationUpdate: (position) {
        print('Foreground Location: ${position.latitude}, ${position.longitude} ${position.accuracy}');

        if (auth != null) {
          gpsService.execute(auth: auth, latlng: LatLng(position.latitude, position.longitude));
          gpsService.syncToBackend(auth: auth);
        }
      },
    );

    _isForegroundTracking = true;
  }

  void stopForegroundTracking() {
    if (!_isForegroundTracking) return;

    _location.stopTracking();
    _isForegroundTracking = false;
  }

  // BACKGROUND TRACKING - Your GeolocatorLocationService already handles notifications!
  Future<bool> startBackgroundTracking() async {
    if (_isBackgroundTracking) return true;

    // Check and request permissions
    if (!await _checkBackgroundPermissions()) {
      return false;
    }

    // Your GeolocatorLocationService already handles foreground notifications on Android
    // So we can directly start continuous tracking with background-optimized distance filter
    final GpsServiceImpl gpsService = GpsServiceImpl(appRepo);
    final auth = getAuth();

    if (auth != null) {
      _location.startContinuousLocationTracking(
        onLocationUpdate: (position) async {
          print('Background Location: ${position.latitude}, ${position.longitude} ${position.accuracy}');

          try {
            await gpsService.execute(auth: auth, latlng: LatLng(position.latitude, position.longitude));
            await gpsService.syncToBackend(auth: auth);
          } catch (e) {
            print('Error processing background location: $e');
          }
        },
        distanceFilter: 15, // Less frequent updates for background to save battery
      );
    }

    _isBackgroundTracking = true;
    return true;
  }

  Future<void> stopBackgroundTracking() async {
    if (!_isBackgroundTracking) return;

    // Stop the location tracking - this will also dismiss Android notification
    _location.stopTracking();
    _isBackgroundTracking = false;
  }

  // SMART TRACKING - Automatically switch between foreground/background
  Future<void> startSmartTracking() async {
    // Start both foreground and background tracking
    startForegroundTracking();
    await startBackgroundTracking();
  }

  Future<void> stopSmartTracking() async {
    stopForegroundTracking();
    await stopBackgroundTracking();
  }

  Future<bool> _checkBackgroundPermissions() async {
    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // For Android 10+, need background location permission
    if (Platform.isAndroid) {
      var backgroundStatus = await Permission.locationAlways.status;
      if (!backgroundStatus.isGranted) {
        backgroundStatus = await Permission.locationAlways.request();
        return backgroundStatus.isGranted;
      }
    }

    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  // Check if background tracking is currently active
  bool isBackgroundTrackingActive() {
    return _isBackgroundTracking;
  }

  // Get current tracking status
  Map<String, bool> getTrackingStatus() {
    return {'foreground': _isForegroundTracking, 'background': _isBackgroundTracking};
  }

  // LIFECYCLE MANAGEMENT - Handle app state changes
  void handleAppLifecycle(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - start high-accuracy tracking
        if (_isBackgroundTracking) {
          startForegroundTracking();
        }
        break;
      case AppLifecycleState.paused:
        // App went to background - foreground tracking will pause automatically
        // Background service continues running
        break;
      case AppLifecycleState.detached:
        // App is closing - keep only background tracking if it was active
        stopForegroundTracking();
        break;
      default:
        break;
    }
  }
}
