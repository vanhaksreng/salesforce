import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:salesforce/core/utils/logger.dart';

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
          await _switchToMode(LocationTrackingMode.foreground, 10.0);
        }
      } else {
        final permissions = await checkPermissions();
        if (permissions['background'] == true) {
          LocationTrackingMode bgMode = _getBestBackgroundMode();
          double distanceFilter = getDistanceFilterForMode(bgMode);
          await _switchToMode(bgMode, distanceFilter);
        }
      }
    } catch (e) {
      _eventController.add({
        'type': 'error',
        'message': 'Failed to switch tracking mode: $e',
      });
    }
  }

  double getDistanceFilterForMode(LocationTrackingMode mode) {
    switch (mode) {
      case LocationTrackingMode.foreground:
        return 10.0;
      case LocationTrackingMode.background:
        return 50.0;
      case LocationTrackingMode.periodic:
        return 100.0;
      case LocationTrackingMode.significant:
        return 200.0;
    }
  }

  Future<void> _switchToMode(
    LocationTrackingMode mode,
    double distanceFilter,
  ) async {
    _currentMode = mode;

    final success = await _channel.invokeMethod('startService', {
      'mode': mode.name,
      'filter': distanceFilter,
    });

    if (success) {
      _eventController.add({
        'type': 'modeSwitch',
        'message': 'Switched to ${mode.name} mode (${distanceFilter}m filter)',
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
    _channel.setMethodCallHandler((call) async {
      final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? {};

      switch (call.method) {
        case 'locationUpdate':
          if (_appActive) {
            _locationController.add(args);
          } else {
            await _saveLocationWhenBackgrounded(args);
          }

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
          _eventController.add({
            'type': 'log',
            'message': args['message'] ?? 'Warning',
          });
          break;
        case 'terminationLocation':
          _eventController.add({'type': 'terminationLocation', ...args});
          break;
        case 'syncLocations':
          _eventController.add({'type': 'syncLocations', ...args});
          break;
        default:
          Logger.log("Unhandled method: ${call.method}");
      }

      return null;
    });

    _isListening = true;
  }

  Future<bool> startTracking({
    required LocationTrackingMode mode,
    double distanceFilter = 0.0,
    double scheduledInterval = 300.0,
  }) async {
    try {
      final res = await _channel.invokeMethod('startService', {
        'mode': mode.name,
        'filter': distanceFilter,
        'scheduledInterval': scheduledInterval,
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

  Future<void> syncPendingLocations() async {
    await _channel.invokeMethod('syncPendingLocations');
  }

  Future<void> _saveLocationWhenBackgrounded(Map<String, dynamic> loc) async {
    Logger.log(
      "GPS bufferFile  processed: ${loc['latitude']}, ${loc['longitude']}",
    );
    try {
      final f = await bufferFile();
      final json = jsonEncode(loc);
      await f.writeAsString('$json\n', mode: FileMode.append, flush: true);
    } catch (e) {
      Logger.log('Failed to buffer location: $e');
    }
  }

  Future<File> bufferFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/location_buffer.jsonl');
  }

  bool get isTracking => _isTracking;
  bool get isAppActive => _isAppActive;
  LocationTrackingMode get currentMode => _currentMode;

  void dispose() {
    _locationController.close();
    _eventController.close();
  }
}
