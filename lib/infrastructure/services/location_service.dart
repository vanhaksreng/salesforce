import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/injection_container.dart';

enum LocationTrackingMode { foreground, background }

class LocationService with WidgetsBindingObserver {
  static const String _channelName =
      'com.clearviewerp.salesforce/background_service';
  static final LocationService instance = LocationService._internal();

  late final MethodChannel _channel;

  final StreamController<Map<String, dynamic>> _locationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _eventController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onLocation => _locationController.stream;
  Stream<Map<String, dynamic>> get onEvent => _eventController.stream;

  bool _isListening = false;
  bool _isTracking = false;
  LocationTrackingMode _currentMode = LocationTrackingMode.foreground;

  final int _syncThreshold = 5;
  int _locationCount = 0;

  final appRepo = getIt<BaseAppRepository>();

  LocationService._internal() {
    _channel = const MethodChannel(_channelName);
    _setupMethodHandler();
    WidgetsBinding.instance.addObserver(this);
  }

  void init() {
    if (_isListening) return;
    _setupMethodHandler();
    _isListening = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isTracking) {
      if (state == AppLifecycleState.resumed) {
        _handleAppStateChange(true);
      } else if (state == AppLifecycleState.paused) {
        _handleAppStateChange(false);
      }
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
          await _switchToMode(LocationTrackingMode.background);
        }
      }
    } on PlatformException catch (e) {
      _eventController.add({
        'type': 'error',
        'message': 'Failed to switch tracking mode: ${e.message}',
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
        'message': 'Switched to ${mode.name} mode',
      });
    }
  }

  void _setupMethodHandler() {
    _channel.setMethodCallHandler((call) async {
      final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? {};

      switch (call.method) {
        case 'locationUpdate':
          await _saveLocationWhenBackgrounded(args);
          break;
        case 'permissionChanged':
          _eventController.add({'type': 'permissionChanged', ...args});
          break;
        case 'trackingStarted':
          _isTracking = true;
          _eventController.add({'type': 'started', ...args});
          break;
        case 'trackingStopped':
          _isTracking = false;
          _eventController.add({'type': 'stopped'});
          break;
        case 'error':
          Logger.log("error: $args");
          _eventController.add({
            'type': 'error',
            'message': args['message'] ?? 'Unknown',
          });
          break;
        case 'syncLocations':
          Logger.log("syncLocations: $args");
          _eventController.add({'type': 'syncLocations', 'data': args['data']});
          break;
        default:
          Logger.log("Unhandled method: ${call.method}");
      }
      return null;
    });
  }

  Future<bool> startTracking({required LocationTrackingMode mode}) async {
    try {
      final res = await _channel.invokeMethod('startService', {
        'mode': mode.name,
      });
      _isTracking = res == true;
      return res == true;
    } on PlatformException catch (e) {
      _eventController.add({'type': 'error', 'message': e.message ?? e.code});
      return false;
    }
  }

  Future<bool> stopTracking() async {
    try {
      final res = await _channel.invokeMethod('stopService');
      _isTracking = !(res == true);
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
      if (Helpers.toDouble(loc['accuracy']) > 15) {
        return;
      }

      await appRepo.storeLocationOffline(
        LatLng(loc['latitude'], loc['longitude']),
      );

      _locationCount++;

      if (_locationCount >= _syncThreshold) {
        await appRepo.syncOfflineLocationToBackend();
        await appRepo.heartbeatStatus(
          params: {'status': 'online', 'rtype': 'heartbeat'},
        );

        _locationCount = 0;
      }
    } catch (e) {
      Logger.log('Failed to buffer location: $e');
    }
  }

  bool get isTracking => _isTracking;
  LocationTrackingMode get currentMode => _currentMode;

  void dispose() {
    _locationController.close();
    _eventController.close();
    WidgetsBinding.instance.removeObserver(this);
  }
}
