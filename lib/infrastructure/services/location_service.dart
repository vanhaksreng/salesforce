import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/constants/app_setting.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/infrastructure/gps/gps_service_impl.dart';
import 'package:salesforce/injection_container.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService with AppMixin {
  static const MethodChannel _channel = MethodChannel('com.clearviewerp.salesforce/location');
  static const EventChannel _eventChannel = EventChannel('com.clearviewerp.salesforce/location_stream');

  final appRepo = getIt<BaseAppRepository>();

  StreamSubscription<dynamic>? _locationSubscription;

  bool _isBackgroundTracking = false;
  String _userGpsTracking = "No";

  double? _lastLatitude;
  double? _lastLongitude;

  static const Map<String, String> _daySettingsKeys = {
    "Monday": kGpsRealTimeTrackingMonday,
    "Tuesday": kGpsRealTimeTrackingTuesDay,
    "Wednesday": kGpsRealTimeTrackingWednesday,
    "Thursday": kGpsRealTimeTrackingThursday,
    "Friday": kGpsRealTimeTrackingFriday,
    "Saturday": kGpsRealTimeTrackingSaturDay,
    "Sunday": kGpsRealTimeTrackingSunday,
  };

  Future<bool> _startBackgroundTracking() async {
    if (_isBackgroundTracking) return true;

    final auth = getAuth();
    if (auth == null) {
      Logger.log("No Auth");
      return false;
    }

    if (!await _checkBackgroundPermissions()) {
      return false;
    }

    final lastGps = await getLastGpsRequest();
    if (lastGps != null) {
      _lastLatitude = lastGps.latitude;
      _lastLongitude = lastGps.longitude;
    }

    final gpsService = GpsServiceImpl(appRepo);

    final result = await _channel.invokeMethod('startTracking');
    if (!result) {
      Logger.log('Background tracking started: $result');
      return false;
    }

    _locationSubscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic locationData) {
        if (_lastLatitude != null && _lastLatitude != null) {
          final distance = Geolocator.distanceBetween(
            _lastLatitude!,
            _lastLongitude!,
            locationData['latitude'],
            locationData['longitude'],
          );

          if (distance < 10) {
            Logger.log('Ignoring small distance change: $distance meters');
            return;
          }
        }

        _lastLatitude = locationData['latitude'];
        _lastLongitude = locationData['longitude'];

        gpsService.execute(auth: auth, latlng: LatLng(locationData['latitude'], locationData['longitude']));
        gpsService.syncToBackend(auth: auth);
      },
      onError: (dynamic error) {
        Logger.log(error.toString());
      },
      onDone: () {
        Logger.log("Location stream closed");
      },
    );

    _isBackgroundTracking = true;
    return true;
  }

  Future<void> _stopBackgroundTracking() async {
    if (!_isBackgroundTracking) return;

    _locationSubscription?.cancel();
    _isBackgroundTracking = false;
  }

  Future<void> startSmartTracking() async {
    Logger.log('GPS startSmartTracking Called');

    _userGpsTracking = await appRepo.getSetting(kGpsRealTimeTracking);
    if (_userGpsTracking != "Yes") {
      Logger.log('GPS tracking disabled globally, skipping initialization');
      stopSmartTracking();
      return;
    }

    final dayName = DateTime.now().dayName();
    final daySettingKey = _daySettingsKeys[dayName];

    if (daySettingKey != null) {
      final daySpecificSetting = await appRepo.getSetting(daySettingKey);
      if (daySpecificSetting.isNotEmpty) {
        _userGpsTracking = daySpecificSetting;
      }
    }

    if (_userGpsTracking != "Yes") {
      Logger.log('GPS tracking disabled for $dayName, skipping initialization');
      stopSmartTracking();
      return;
    }

    await _startBackgroundTracking();
  }

  Future<void> stopSmartTracking() async {
    await _stopBackgroundTracking();
  }

  Future<bool> _checkBackgroundPermissions() async {
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

  bool isBackgroundTrackingActive() {
    return _isBackgroundTracking;
  }
}
