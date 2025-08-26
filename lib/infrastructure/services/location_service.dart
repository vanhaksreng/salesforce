import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/injection_container.dart';

enum LocationTrackingMode { foreground, background, significant, periodic }

class LocationService {
  static const String _channelName =
      'com.clearviewerp.salesforce/background_service';
  static final LocationService instance = LocationService._internal();
  final MethodChannel _channel = const MethodChannel(_channelName);

  // Stream controllers
  final StreamController<Map<String, dynamic>> _locationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _eventController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Public streams (matching your existing API)
  Stream<Map<String, dynamic>> get onLocation => _locationController.stream;
  Stream<Map<String, dynamic>> get onEvent => _eventController.stream;

  bool _isListening = false;
  bool _appActive = true;
  final bool _isAppActive = true;
  LocationTrackingMode _currentMode = LocationTrackingMode.foreground;
  final bool _isTracking = false;

  int locationCount = 0;

  final appRepo = getIt<BaseAppRepository>();

  LocationService._internal() {
    _setupMethodHandler();
  }

  void setAppActive(bool active) {
    final wasActive = _isAppActive;
    _appActive = active;

    if (_isTracking && wasActive != active) {
      _handleAppStateChange(active);
    }
  }

  Future<void> _handleAppStateChange(bool isAppActive) async {
    try {
      if (isAppActive) {
        final permissions = await checkPermissions();
        if (permissions['canTrackForeground'] == true) {
          await _switchToMode(LocationTrackingMode.foreground);
        }
      } else {
        final permissions = await checkPermissions();
        if (permissions['background'] == true) {
          await _switchToMode(_getBestBackgroundMode());
        }
      }
    } catch (e) {
      _eventController.add({
        'type': 'error',
        'message': 'Failed to switch tracking mode: $e',
      });
    }
  }

  Future<void> _switchToMode(LocationTrackingMode mode) async {
    _currentMode = mode;

    final success = await _channel.invokeMethod('startService', {
      'mode': mode.name,
    });

    if (success) {
      _eventController.add({
        'type': 'modeSwitch',
        'message': 'Switched to ${mode.name} mode)',
      });
    }
  }

  LocationTrackingMode _getBestBackgroundMode() {
    // You can make this configurable or add user preferences
    // Periodic is a good balance of accuracy and battery life
    return LocationTrackingMode.periodic;
  }

  void _setupMethodHandler() {
    if (_isListening) return;

    try {
      _channel.setMethodCallHandler((call) async {
        final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? {};

        switch (call.method) {
          case 'locationUpdate':
            // if (_appActive) {
            //   _locationController.add(args);
            // } else {
            //   await _saveLocationWhenBackgrounded(args);
            // }

            await _saveLocationWhenBackgrounded(args);

            break;
          case 'permissionStatus':
            _locationController.add(args);
            break;
          case 'permissionChanged':
            _eventController.add({'type': 'permissionChanged', ...args});
            break;
          case 'trackingStarted':
            _eventController.add({'type': 'started', ...args});
            break;
          case 'trackingStopped':
            _eventController.add({'type': 'stopped'});
            break;
          case 'error':
            _eventController.add({
              'type': 'error',
              'message': args['message'] ?? 'Unknown',
            });
            break;
          case 'log':
            Logger.log(args['message']);
            break;
          case 'terminationLocation':
            _eventController.add({'type': 'terminationLocation', ...args});
            break;
          case 'syncLocations':
            Logger.log("syncLocations: $args");
            _eventController.add({
              'type': 'syncLocations',
              'data': args['data'],
            });
            break;
          default:
            Logger.log("Unhandled method: ${call.method}");
        }

        return null;
      });
    } catch (e) {
      Logger.log("Error Called method: $e");
    }

    _isListening = true;
  }

  Future<bool> startTracking({required LocationTrackingMode mode}) async {
    try {
      final res = await _channel.invokeMethod('startService', {
        'mode': mode.name,
      });
      return res == true;
    } on PlatformException catch (e) {
      _eventController.add({'type': 'error', 'message': e.message ?? e.code});
      return false;
    }
  }

  Future<bool> stopTracking() async {
    try {
      final res = await _channel.invokeMethod('stopService');
      return res == true;
    } on PlatformException catch (e) {
      _eventController.add({'type': 'error', 'message': e.message ?? e.code});
      return false;
    }
  }

  Future<bool> requestPermissions(LocationTrackingMode mode) async {
    try {
      final res = await _channel.invokeMethod('requestPermissions', {
        'mode': mode.name,
      });
      return res == true;
    } on PlatformException catch (e) {
      _eventController.add({'type': 'error', 'message': e.message ?? e.code});
      return false;
    }
  }

  Future<Map<String, dynamic>> checkPermissions() async {
    try {
      final res = await _channel.invokeMethod('checkPermissions');
      return (res as Map).cast<String, dynamic>();
    } on PlatformException catch (e) {
      _eventController.add({'type': 'error', 'message': e.message ?? e.code});
      return {'canTrackForeground': false, 'background': false};
    }
  }

  Future<void> _saveLocationWhenBackgrounded(Map<String, dynamic> loc) async {
    try {
      await appRepo.storeLocationOffline(
        LatLng(loc['latitude'], loc['longitude']),
      );

      if (!_appActive && locationCount >= 0) {
        await appRepo.syncOfflineLocationToBackend();
        await appRepo.heartbeatStatus(
          params: {'status': 'online', 'rtype': 'heartbeat'},
        );

        Logger.log('syncOfflineLocationToBackend.... $locationCount');

        locationCount = 0;
      }

      locationCount += 1;
    } catch (e) {
      Logger.log('Failed to buffer location: $e');
    }
  }

  bool get isTracking => _isTracking;
  bool get isAppActive => _isAppActive;
  LocationTrackingMode get currentMode => _currentMode;

  void dispose() {
    _locationController.close();
    _eventController.close();
  }
}
