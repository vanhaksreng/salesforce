// import 'dart:async';
// import 'package:flutter/services.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:salesforce/core/constants/app_setting.dart';
// import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
// import 'package:salesforce/core/utils/date_extensions.dart';
// import 'package:salesforce/core/utils/helpers.dart';
// import 'package:salesforce/core/utils/logger.dart';
// import 'package:salesforce/features/auth/domain/entities/user.dart';
// import 'package:salesforce/infrastructure/gps/gps_service_impl.dart';
// import 'package:salesforce/infrastructure/heartbeat/heartbeat_service_impl.dart';
// import 'package:salesforce/injection_container.dart';

// class BackgroundService {
//   static const MethodChannel _channel = MethodChannel('com.clearviewerp.salesforce/background_service');
//   static bool _isRunning = false;
//   static User? _currentUser;
//   static GpsServiceImpl? _gpsService;
//   static HeartbeatServiceImpl? _heartbeatService;
//   static double _distanceFilter = 50.0; // Default to 50 meters
//   static Timer? _syncTimer;
//   static Timer? _heartbeatTimer;
//   static String _userGpsTracking = "Yes";
//   static Duration periodicSyncMin = const Duration(minutes: 5);
//   static Duration heatBeatDuration = const Duration(minutes: 2);

//   // Day-specific GPS tracking settings mapping
//   static const Map<String, String> _daySettingsKeys = {
//     "Monday": kGpsRealTimeTrackingMonday,
//     "Tuesday": kGpsRealTimeTrackingTuesDay,
//     "Wednesday": kGpsRealTimeTrackingWednesday,
//     "Thursday": kGpsRealTimeTrackingThursday,
//     "Friday": kGpsRealTimeTrackingFriday,
//     "Saturday": kGpsRealTimeTrackingSaturDay,
//     "Sunday": kGpsRealTimeTrackingSunday,
//   };

//   static Future<void> initialize() async {
//     try {
//       final appRepo = getIt<BaseAppRepository>();
//       _gpsService = GpsServiceImpl(appRepo);
//       _heartbeatService = HeartbeatServiceImpl(appRepo);
//       _currentUser = getAuth();

//       // Check if GPS tracking is enabled globally
//       _userGpsTracking = await appRepo.getSetting(kGpsRealTimeTracking);
//       Logger.log('Global GPS tracking setting: $_userGpsTracking');

//       if (_userGpsTracking != "Yes") {
//         Logger.log('GPS tracking disabled globally, skipping initialization');
//         return;
//       }

//       // Check day-specific settings
//       final dayName = DateTime.now().dayName();
//       final daySettingKey = _daySettingsKeys[dayName];
//       Logger.log('Checking day-specific setting for $dayName');

//       if (daySettingKey != null) {
//         final daySpecificSetting = await appRepo.getSetting(daySettingKey);
//         if (daySpecificSetting.isNotEmpty) {
//           _userGpsTracking = daySpecificSetting;
//           Logger.log('Day-specific GPS tracking setting for $dayName: $_userGpsTracking');
//         }
//       }

//       if (_userGpsTracking != "Yes") {
//         Logger.log('GPS tracking disabled for $dayName, skipping initialization');
//         return;
//       }

//       // Get distance filter setting
//       final distanceFilterSetting = await appRepo.getSetting(kGpsRealTimeTrackingInterval);
//       if (distanceFilterSetting.isNotEmpty) {
//         final parsedFilter = Helpers.toDouble(distanceFilterSetting);
//         if (parsedFilter > 0) {
//           _distanceFilter = parsedFilter;
//           Logger.log('Distance filter set to: $_distanceFilter meters');
//         }
//       }

//       _setupNativeCallbacks();
//       Logger.log('BackgroundService initialized successfully');
//     } catch (e) {
//       Logger.log('Failed to initialize BackgroundService: $e');
//       rethrow;
//     }
//   }

//   static Future<void> startService({double? distanceFilter}) async {
//     // Sync any pending data first
//     if (_currentUser != null && _gpsService != null) {
//       try {
//         await _gpsService!.syncToBackend(auth: _currentUser!);
//         Logger.log('Initial sync to backend completed');
//       } catch (e) {
//         Logger.log('Initial sync failed: $e');
//       }
//     }

//     if (_isRunning) {
//       Logger.log('Service already running, skipping start');
//       return;
//     }

//     if (_userGpsTracking != "Yes") {
//       Logger.log('GPS tracking disabled, cannot start service');
//       return;
//     }

//     try {
//       // Check permissions first
//       final permission = await checkPermissions();
//       Logger.log('Permission status: $permission');

//       if (!permission['canTrackForeground']) {
//         Logger.log('Requesting location permissions...');
//         await requestPermissions();

//         // Wait longer for permission dialog to complete
//         await Future.delayed(const Duration(seconds: 2));

//         // Check permissions again after request
//         final newPermission = await checkPermissions();
//         Logger.log('Permission status after request: $newPermission');

//         if (!newPermission['canTrackForeground']) {
//           Logger.log('Location permissions still not granted, cannot start service');
//           return;
//         }
//       }

//       // Set distance filter
//       _distanceFilter = distanceFilter ?? _distanceFilter;
//       Logger.log('Using distance filter: $_distanceFilter meters');

//       // Start the native service
//       final bool result = await _channel.invokeMethod('startService', {'filter': _distanceFilter});

//       if (result) {
//         _isRunning = true;
//         // _startPeriodicSync();
//         _startHeartbeat();
//         Logger.log('BackgroundService started successfully with distance filter: $_distanceFilter meters');
//       } else {
//         Logger.log('Failed to start native service');
//         throw Exception('Native service failed to start');
//       }
//     } catch (e) {
//       Logger.log('Failed to start BackgroundService: $e');
//       rethrow;
//     }
//   }

//   static Future<void> stopService() async {
//     if (!_isRunning) {
//       Logger.log('Service not running, skipping stop');
//       return;
//     }

//     try {
//       Logger.log('Stopping GPS tracking service...');
//       await _channel.invokeMethod('stopService');

//       _syncTimer?.cancel();
//       _heartbeatTimer?.cancel();
//       _isRunning = false;

//       Logger.log('BackgroundService stopped successfully');
//     } catch (e) {
//       Logger.log('Failed to stop BackgroundService: $e');
//       rethrow;
//     }
//   }

//   static Future<Map<String, dynamic>> checkPermissions() async {
//     try {
//       final result = await _channel.invokeMethod('checkPermissions');
//       return Map<String, dynamic>.from(result);
//     } catch (e) {
//       return {
//         'fine': false,
//         'coarse': false,
//         'background': false,
//         'canTrackForeground': false,
//         'canTrackBackground': false,
//       };
//     }
//   }

//   static Future<bool> requestPermissions() async {
//     try {
//       final result = await _channel.invokeMethod('requestPermissions');
//       return result ?? false;
//     } catch (e) {
//       Logger.log('Error requesting permissions: $e');
//       return false;
//     }
//   }

//   static Future<LatLng?> getCurrentLocation({
//     Duration timeout = const Duration(seconds: 60),
//   }) async {
//     try {
//       final result = await _channel.invokeMethod('getCurrentLocation', {
//         'timeout': timeout.inSeconds,
//       });

//       if (result != null) {
//         final locationData = Map<String, dynamic>.from(result);
//         return LatLng(locationData['latitude'] as double, locationData['longitude'] as double);
//       }

//       return null;
//     } catch (e) {
//       Logger.log('Error getting current location: $e');
//       return null;
//     }
//   }

//   static Future<void> _setupNativeCallbacks() async {
//     _channel.setMethodCallHandler((call) async {
//       try {
//         switch (call.method) {
//           case 'locationUpdate':
//             await _handleLocationUpdate(Map<String, dynamic>.from(call.arguments));
//             break;
//           case 'backgroundSync':
//             await _handleBackgroundSync(Map<String, dynamic>.from(call.arguments));
//             break;
//           case 'terminationSync':
//             await _handleTerminationSync();
//             break;
//           case 'permissionStatus':
//             await _handlePermissionStatus(Map<String, dynamic>.from(call.arguments));
//             break;
//           case 'error':
//             _handleError(call.arguments);
//             break;
//           case 'log':
//             _handleLog(call.arguments);
//             break;
//           case 'warning':
//             _handleWarning(call.arguments);
//             break;
//           default:
//             Logger.log('Unknown callback method: ${call.method}');
//         }
//       } catch (e) {
//         Logger.log('Error handling native callback ${call.method}: $e');
//       }
//     });
//   }

//   static Future<void> _handleLocationUpdate(Map<String, dynamic> arguments) async {
//     if (!_isRunning || _gpsService == null || _currentUser == null) {
//       Logger.log('Ignoring location update: service not running or not initialized');
//       return;
//     }

//     try {
//       final double latitude = arguments['latitude'] as double;
//       final double longitude = arguments['longitude'] as double;

//       Logger.log('Location update: $latitude,$longitude');

//       // await _gpsService!.execute(
//       //   auth: _currentUser!,
//       //   latlng: LatLng(latitude, longitude),
//       // );

//       // await _handleTerminationSync();
//     } catch (e) {
//       Logger.log('Error handling location update: $e');
//     }
//   }

//   static Future<void> _handleBackgroundSync(Map<String, dynamic> arguments) async {
//     Logger.log('handleBackgroundSync: $arguments');

//     if (!_isRunning || _currentUser == null || _gpsService == null) {
//       Logger.log('Ignoring background sync: service not running or not initialized');
//       return;
//     }

//     try {
//       await _gpsService!.syncToBackend(auth: _currentUser!);
//       Logger.log('Background sync completed successfully');
//     } catch (e) {
//       Logger.log('Background sync error: $e');
//     }
//   }

//   static Future<void> _handleTerminationSync() async {
//     Logger.log('Handling termination sync...');

//     if (!_isRunning || _currentUser == null || _gpsService == null) {
//       Logger.log('Cannot process termination sync: Service not running or not initialized');
//       return;
//     }

//     try {
//       await _gpsService!.syncToBackend(auth: _currentUser!).timeout(
//         const Duration(seconds: 5), // Increased timeout for termination sync
//         onTimeout: () {
//           Logger.log('Termination sync timed out, data stored locally');
//         },
//       );
//       Logger.log('Termination sync completed successfully');
//     } catch (e) {
//       Logger.log('Termination sync error: $e');
//     }
//   }

//   static void _handleError(dynamic arguments) {
//     final Map<String, dynamic> errorData = Map<String, dynamic>.from(arguments);
//     Logger.log('Native error: ${errorData['message']}');
//   }

//   static void _handleLog(dynamic arguments) {
//     final Map<String, dynamic> logData = Map<String, dynamic>.from(arguments);
//     Logger.log('Native log: ${logData['message']}');
//   }

//   static void _handleWarning(dynamic arguments) {
//     final Map<String, dynamic> warningData = Map<String, dynamic>.from(arguments);
//     Logger.log('Native warning: ${warningData['message']}');
//   }

//   static Future<void> _handlePermissionStatus(Map<String, dynamic> arguments) async {
//     final bool canTrackForeground = arguments['canTrackForeground'] == true;
//     final bool canTrackBackground = arguments['canTrackBackground'] == true;

//     Logger.log('Permission status update - Foreground: $canTrackForeground, Background: $canTrackBackground');

//     if (!canTrackForeground && _isRunning) {
//       Logger.log('Permissions revoked, stopping service');
//       await stopService();
//     } else if (canTrackForeground && !_isRunning && _userGpsTracking == "Yes") {
//       try {
//         await startService(distanceFilter: _distanceFilter);
//       } catch (e) {
//         Logger.log('Failed to auto-start service after permission grant: $e');
//       }
//     }
//   }

//   // static Future<void> _startPeriodicSync() async {
//   //   _syncTimer?.cancel();
//   //   Logger.log('Starting periodic sync every 3 minutes...');

//   //   _syncTimer = Timer.periodic(periodicSyncMin, (timer) async {
//   //     if (!_isRunning || _currentUser == null || _gpsService == null) {
//   //       Logger.log('Cancelling periodic sync: service stopped or not initialized');
//   //       timer.cancel();
//   //       return;
//   //     }

//   //     try {
//   //       await _gpsService!.syncToBackend(auth: _currentUser!);
//   //       Logger.log('Periodic sync completed successfully');
//   //     } catch (e) {
//   //       Logger.log('Periodic sync error: $e');
//   //     }
//   //   });
//   // }

//   static Future<void> _startHeartbeat() async {
//     _heartbeatTimer?.cancel();

//     _heartbeatTimer = Timer.periodic(heatBeatDuration, (timer) async {
//       if (!_isRunning || _currentUser == null || _heartbeatService == null) {
//         Logger.log('Cancelling heartbeat: service stopped or not initialized');
//         timer.cancel();
//         return;
//       }

//       try {
//         await _heartbeatService!.execute(auth: _currentUser!);
//         Logger.log('Heartbeat sent successfully');
//       } catch (e) {
//         Logger.log('Heartbeat error: $e');
//       }
//     });
//   }

//   // static Future<void> triggerSync() async {
//   //   if (!_isRunning || _currentUser == null || _gpsService == null) {
//   //     Logger.log('Cannot trigger sync: service not running or not initialized');
//   //     return;
//   //   }

//   //   try {
//   //     Logger.log('Triggering manual sync...');
//   //     await _gpsService!.syncToBackend(auth: _currentUser!);
//   //     Logger.log('Manual sync completed successfully');
//   //   } catch (e) {
//   //     Logger.log('Manual sync error: $e');
//   //   }
//   // }

//   // static Future<void> checkAndStartService() async {
//   //   if (_isRunning) {
//   //     Logger.log('Service already running');
//   //     return;
//   //   }

//   //   if (_userGpsTracking != "Yes") {
//   //     Logger.log('GPS tracking disabled, cannot auto-start service');
//   //     return;
//   //   }

//   //   try {
//   //     final permissions = await checkPermissions();
//   //     if (permissions['canTrackForeground'] == true) {
//   //       Logger.log('Permissions available, auto-starting service');
//   //       await startService(distanceFilter: _distanceFilter);
//   //     } else {
//   //       Logger.log('Permissions not available for auto-start');
//   //     }
//   //   } catch (e) {
//   //     Logger.log('Error in checkAndStartService: $e');
//   //   }
//   // }

//   // Getters for debugging
//   static bool get isRunning => _isRunning;
//   static double get distanceFilter => _distanceFilter;
//   static String get gpsTrackingStatus => _userGpsTracking;
// }
