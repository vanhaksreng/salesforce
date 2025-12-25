// import 'dart:async';

// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
// import 'package:salesforce/core/utils/logger.dart';
// import 'package:salesforce/features/auth/domain/entities/user.dart';
// import 'package:salesforce/infrastructure/external_services/location/geolocator_location_service.dart';
// import 'package:salesforce/infrastructure/external_services/location/i_location_service.dart';
// import 'package:salesforce/infrastructure/external_services/location/location_permission_status.dart';
// import 'package:salesforce/infrastructure/gps/gps_service.dart';
// import 'package:salesforce/infrastructure/heartbeat/heartbeat_service.dart';
// import 'package:salesforce/infrastructure/services/location_service.dart';
// import 'package:salesforce/injection_container.dart';
// import 'package:permission_handler/permission_handler.dart' as perm;

// class UnifiedLocationManager {
//   static UnifiedLocationManager? _instance;
//   static UnifiedLocationManager get instance =>
//       _instance ??= UnifiedLocationManager._internal();

//   UnifiedLocationManager._internal();

//   // Services
//   late final IGpsService _gpsService;
//   late final IHeartbeatService _heartbeatService;
//   late final ILocationService _geolocationService;

//   // State
//   bool _isInitialized = false;

//   // Timers
//   Timer? _syncTimer;
//   Timer? _heartbeatTimer;

//   // Getters
//   bool get isInitialized => _isInitialized;

//   Future<void> initialize({
//     required BaseAppRepository appRepo,
//     required IGpsService gpsService,
//     required IHeartbeatService heartbeatService,
//   }) async {
//     if (_isInitialized) return;

//     _gpsService = gpsService;
//     _heartbeatService = heartbeatService;
//     _geolocationService = GeolocatorLocationService();

//     await _setupLocationListeners();

//     _isInitialized = true;
//     Logger.log("UnifiedLocationManager initialized");
//   }

//   void dispose() {
//     _stopAllTimers();
//     _isInitialized = false;
//   }

//   void setAppLifecycleState(bool isActive) {
//     if (isActive) {
//       _handleAppResumed();
//     } else {
//       _handleAppBackground();
//     }
//   }

//   // MARK: - Permission Management
//   // Future<bool> requestAllPermissions() async {
//   //   try {
//   //     // Check current location permission status
//   //     final locationStatus = await _geolocationService.checkPermission();
//   //     if (shouldShowPermissionDialog(locationStatus)) {
//   //       return false;
//   //     }

//   //     // Request foreground permission first
//   //     // final fgGranted = await _locationService.requestPermissions(
//   //     //   LocationTrackingMode.foreground,
//   //     // );

//   //     // if (!fgGranted) {
//   //     //   Logger.log("Foreground location permission denied");
//   //     //   return false;
//   //     // }

//   //     // // Request background permission
//   //     // final bgGranted = await _locationService.requestPermissions(
//   //     //   LocationTrackingMode.periodic,
//   //     // );

//   //     // _hasBackgroundPermission = bgGranted;

//   //     // Logger.log(
//   //     //   "Permissions - Foreground: $fgGranted, Background: $bgGranted",
//   //     // );
//   //     // return fgGranted;

//   //     return true;
//   //   } catch (e) {
//   //     Logger.log("Permission request failed: $e");
//   //     return false;
//   //   }
//   // }

//   Future<void> _syncGpsData({required dynamic auth}) async {
//     try {
//       await _gpsService.syncToBackend(auth: auth);
//       Logger.log("GPS data synced to backend");
//     } catch (e) {
//       Logger.log("Error syncing GPS data: $e");
//     }
//   }

//   Future<void> _syncHeartbeat({required dynamic auth}) async {
//     try {
//       await _heartbeatService.execute(auth: auth);
//       Logger.log("Heartbeat synced");
//     } catch (e) {
//       Logger.log("Error syncing heartbeat: $e");
//     }
//   }

//   // MARK: - Event Handlers
//   Future<void> _setupLocationListeners() async {
//     _geolocationService.startContinuousLocationTracking(
//       distanceFilter: 3,
//       onLocationUpdate: (Position position) async {
//         if (position.accuracy > 10) {
//           return;
//         }

//         Logger.log(
//           "latitude:${position.latitude}, longitude:${position.longitude}, accuracy:${position.accuracy} ",
//         );

//         await _gpsService.execute(
//           latlng: LatLng(position.latitude, position.longitude),
//         );
//       },
//     );
//   }

//   // MARK: - App Lifecycle Handlers
//   Future<void> _handleAppResumed() async {
//     _startPeriodicSync();
//   }

//   Future<void> _handleAppBackground() async {
//     _stopAllTimers();
//   }

//   // MARK: - Timer Management
//   void _startPeriodicSync() {
//     _stopAllTimers();

//     // Sync GPS data every 60 seconds
//     _syncTimer = Timer.periodic(const Duration(seconds: 60), (_) async {
//       final auth = await _getCurrentAuth();
//       if (auth != null) {
//         await _syncGpsData(auth: auth);
//       }
//     });

//     // Sync heartbeat every 90 seconds
//     _heartbeatTimer = Timer.periodic(const Duration(seconds: 90), (_) async {
//       final auth = await _getCurrentAuth();
//       if (auth != null) {
//         await _syncHeartbeat(auth: auth);
//       }
//     });
//   }

//   void _stopAllTimers() {
//     _syncTimer?.cancel();
//     _syncTimer = null;
//     _heartbeatTimer?.cancel();
//     _heartbeatTimer = null;
//   }

//   Future<User?> _getCurrentAuth() async {
//     return getAuth();
//   }

//   // MARK: - Public API for showing permission dialog
//   bool shouldShowPermissionDialog(LocationPermissionStatus status) {
//     // return status == LocationPermissionStatus.denied ||
//     return status == LocationPermissionStatus.deniedForever;
//   }

//   Future<void> openAppSettings() async {
//     await perm.openAppSettings();
//   }
// }
