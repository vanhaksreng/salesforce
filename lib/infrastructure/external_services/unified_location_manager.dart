import 'dart:async';
import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/features/auth/domain/entities/user.dart';
import 'package:salesforce/infrastructure/external_services/location/geolocator_location_service.dart';
import 'package:salesforce/infrastructure/external_services/location/i_location_service.dart';
import 'package:salesforce/infrastructure/external_services/location/location_permission_status.dart';
import 'package:salesforce/infrastructure/gps/gps_service.dart';
import 'package:salesforce/infrastructure/heartbeat/heartbeat_service.dart';
import 'package:salesforce/infrastructure/services/location_service.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:permission_handler/permission_handler.dart' as perm;

class UnifiedLocationManager {
  static UnifiedLocationManager? _instance;
  static UnifiedLocationManager get instance =>
      _instance ??= UnifiedLocationManager._internal();

  UnifiedLocationManager._internal();

  // Services
  late final LocationService _locationService;
  late final IGpsService _gpsService;
  late final IHeartbeatService _heartbeatService;
  late final ILocationService _geolocationService;
  late final BaseAppRepository _appRepo;

  // State
  bool _isInitialized = false;
  bool _hasBackgroundPermission = false;
  bool _isAppActive = true;
  String? _currentSaleCode;

  // Timers
  Timer? _syncTimer;
  Timer? _heartbeatTimer;

  // Subscriptions
  StreamSubscription? _locationSubscription;
  StreamSubscription? _eventSubscription;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get hasBackgroundPermission => _hasBackgroundPermission;
  bool get isTracking => _locationService.isTracking;

  Future<void> initialize({
    required BaseAppRepository appRepo,
    required IGpsService gpsService,
    required IHeartbeatService heartbeatService,
  }) async {
    if (_isInitialized) return;

    _appRepo = appRepo;
    _gpsService = gpsService;
    _heartbeatService = heartbeatService;
    _locationService = LocationService.instance;
    _geolocationService = GeolocatorLocationService();

    await _setupLocationListeners();
    await _checkInitialPermissions();

    _isInitialized = true;
    Logger.log("UnifiedLocationManager initialized");
  }

  void dispose() {
    _stopAllTimers();
    _locationSubscription?.cancel();
    _eventSubscription?.cancel();
    _isInitialized = false;
  }

  void setAppLifecycleState(bool isActive) {
    _isAppActive = isActive;
    _locationService.setAppActive(isActive);

    if (isActive) {
      _handleAppResumed();
    } else {
      _handleAppBackground();
    }
  }

  // MARK: - Permission Management
  Future<bool> requestAllPermissions() async {
    try {
      // Check current location permission status
      final locationStatus = await _geolocationService.checkPermission();
      if (shouldShowPermissionDialog(locationStatus)) {
        return false;
      }

      // Request foreground permission first
      final fgGranted = await _locationService.requestPermissions(
        LocationTrackingMode.foreground,
      );

      if (!fgGranted) {
        Logger.log("Foreground location permission denied");
        return false;
      }

      // Request background permission
      final bgGranted = await _locationService.requestPermissions(
        LocationTrackingMode.periodic,
      );

      _hasBackgroundPermission = bgGranted;

      Logger.log(
        "Permissions - Foreground: $fgGranted, Background: $bgGranted",
      );
      return fgGranted;
    } catch (e) {
      Logger.log("Permission request failed: $e");
      return false;
    }
  }

  Future<void> _checkInitialPermissions() async {
    final permissions = await _locationService.checkPermissions();
    _hasBackgroundPermission = permissions['background'] == true;
  }

  // MARK: - Location Tracking
  Future<bool> startLocationTracking() async {
    try {
      final permissions = await _locationService.checkPermissions();
      _hasBackgroundPermission = permissions['background'] == true;

      LocationTrackingMode mode;
      if (_hasBackgroundPermission) {
        mode = LocationTrackingMode.periodic;
      } else if (permissions['canTrackForeground'] == true) {
        mode = LocationTrackingMode.foreground;
      } else {
        Logger.log("No location permissions available");
        return false;
      }

      final success = await _locationService.startTracking(
        mode: mode,
        distanceFilter: _locationService.getDistanceFilterForMode(mode),
      );

      if (success) {
        Logger.log("Location tracking started in $mode mode");
      }

      return success;
    } catch (e) {
      Logger.log("Failed to start location tracking: $e");
      return false;
    }
  }

  Future<void> stopLocationTracking() async {
    await _locationService.stopTracking();
    Logger.log("Location tracking stopped");
  }

  // MARK: - Background Sync & Data Processing
  Future<void> syncAllData({required dynamic auth}) async {
    await _syncBufferedLocations();
    await _syncGpsData(auth: auth);
    await _syncHeartbeat(auth: auth);
  }

  Future<void> _syncGpsData({required dynamic auth}) async {
    try {
      await _gpsService.syncToBackend(auth: auth);
      Logger.log("GPS data synced to backend");
    } catch (e) {
      Logger.log("Error syncing GPS data: $e");
    }
  }

  Future<void> _syncHeartbeat({required dynamic auth}) async {
    try {
      await _heartbeatService.execute(auth: auth);
      Logger.log("Heartbeat synced");
    } catch (e) {
      Logger.log("Error syncing heartbeat: $e");
    }
  }

  Future<void> syncPendingLocations() async {
    await _locationService.syncPendingLocations();
  }

  Future<void> _syncBufferedLocations() async {
    try {
      final bufferFile = await _locationService.bufferFile();
      if (!await bufferFile.exists()) return;

      final lines = await bufferFile.readAsLines();
      if (lines.isEmpty) {
        await bufferFile.delete();
        return;
      }

      final gpsRecords = await _parseLocationLines(lines);
      if (gpsRecords.isNotEmpty) {
        await _storeAndSyncGpsRecords(gpsRecords);
      }

      await bufferFile.delete();
      Logger.log("Buffered locations synced: ${gpsRecords.length} records");
    } catch (e) {
      Logger.log("Failed to sync buffered locations: $e");
    }
  }

  // MARK: - Data Processing Helpers
  Future<List<GpsRouteTracking>> _parseLocationLines(List<String> lines) async {
    final gpsRecords = <GpsRouteTracking>[];
    final saleCode = await _getCurrentSaleCode();

    if (saleCode.isEmpty) return gpsRecords;

    for (int i = 0; i < lines.length; i++) {
      try {
        final Map data = jsonDecode(lines[i]);
        final record = _createGpsRecord(data, saleCode);
        if (record != null) {
          gpsRecords.add(record);
        }
      } catch (e) {
        Logger.log("Failed to parse GPS record at line ${i + 1}: $e");
      }
    }

    return gpsRecords;
  }

  Future<void> _processLocationData(List<dynamic> locationData) async {
    if (locationData.isEmpty) return;

    final saleCode = await _getCurrentSaleCode();
    if (saleCode.isEmpty) return;

    final gpsRecords = <GpsRouteTracking>[];
    for (var data in locationData) {
      Logger.log("_processLocationData $data");
      final record = _createGpsRecord(data, saleCode);
      if (record != null) {
        gpsRecords.add(record);
      }
    }

    if (gpsRecords.isNotEmpty) {
      await _storeAndSyncGpsRecords(gpsRecords);
      Logger.log("Processed ${gpsRecords.length} location records");
    }
  }

  GpsRouteTracking? _createGpsRecord(Map data, String saleCode) {
    if (!data.containsKey('latitude') ||
        !data.containsKey('longitude') ||
        !data.containsKey('timestamp')) {
      return null;
    }

    try {
      return GpsRouteTracking(
        saleCode,
        (data['latitude'] as num).toDouble(),
        (data['longitude'] as num).toDouble(),
        DateTime.parse(data['timestamp'] as String).toDateString(),
        DateTime.parse(data['timestamp'] as String).toDateTimeString(),
        isSync: "No",
      );
    } catch (e) {
      Logger.log("Error creating GPS record: $e");
      return null;
    }
  }

  Future<void> _storeAndSyncGpsRecords(List<GpsRouteTracking> records) async {
    try {
      await _gpsService.storeGps(records: records);

      final auth = await _getCurrentAuth();
      if (auth != null) {
        await _gpsService.syncToBackend(auth: auth);
      }
    } catch (e) {
      Logger.log("Error storing/syncing GPS records: $e");
    }
  }

  // MARK: - Event Handlers
  Future<void> _setupLocationListeners() async {
    _locationSubscription = _locationService.onLocation.listen((
      location,
    ) async {
      try {
        await _gpsService.execute(
          latlng: LatLng(location['latitude'], location['longitude']),
        );
      } catch (e) {
        Logger.log("Error processing GPS location: $e");
      }
    });

    // Service events
    _eventSubscription = _locationService.onEvent.listen((event) {
      final type = event['type'] ?? 'unknown';
      switch (type) {
        case 'error':
          _handleLocationError(event['message'] ?? '');
          break;
        case 'permissionChanged':
          _handlePermissionChange(event);
          break;
        case 'syncLocations':
          _processLocationData(event['data'] ?? []);
          break;
      }
    });
  }

  void _handleLocationError(String error) {
    if (error.contains('permission')) {
      Logger.log("Location permission error - may need user intervention");
    } else {
      Logger.log("Location error: $error");
    }
  }

  void _handlePermissionChange(Map<String, dynamic> event) async {
    final status = event['status'];

    if (status == null) {
      return;
    }

    if (status == "authorizedWhenInUse") {
      await _locationService.requestPermissions(
        LocationTrackingMode.background,
      );
    }

    if (['authorizedAlways', 'authorizedWhenInUse'].contains(status)) {
      _hasBackgroundPermission = status == 'authorizedAlways';

      if (!_locationService.isTracking) {
        startLocationTracking();
      }
    }
  }

  // MARK: - App Lifecycle Handlers
  Future<void> _handleAppResumed() async {
    await _syncBufferedLocations();
    _startPeriodicSync();
  }

  Future<void> _handleAppBackground() async {
    _stopAllTimers();

    // If we have background permission, switch to background tracking
    if (_hasBackgroundPermission && _locationService.isTracking) {
      await _locationService.startTracking(
        mode: LocationTrackingMode.significant,
        distanceFilter: 30.0,
      );
    }
  }

  // MARK: - Timer Management
  void _startPeriodicSync() {
    _stopAllTimers();

    // Sync GPS data every 60 seconds
    _syncTimer = Timer.periodic(const Duration(seconds: 60), (_) async {
      final auth = await _getCurrentAuth();
      if (auth != null) {
        await _syncGpsData(auth: auth);
      }
    });

    // Sync heartbeat every 90 seconds
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 90), (_) async {
      final auth = await _getCurrentAuth();
      if (auth != null) {
        await _syncHeartbeat(auth: auth);
      }
    });
  }

  void _stopAllTimers() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  // MARK: - Utility Methods
  Future<String> _getCurrentSaleCode() async {
    if (_currentSaleCode != null && _currentSaleCode!.isNotEmpty) {
      return _currentSaleCode!;
    }

    final auth = await _getCurrentAuth();
    if (auth?.salepersonCode.isNotEmpty == true) {
      _currentSaleCode = auth?.salepersonCode ?? "";
      return _currentSaleCode!;
    }

    // Fallback to user setup
    final response = await _appRepo.getUserSetup();
    return response.fold((l) => "", (r) {
      _currentSaleCode = r?.salespersonCode ?? "";
      return _currentSaleCode!;
    });
  }

  Future<User?> _getCurrentAuth() async {
    return getAuth();
  }

  // MARK: - Public API for showing permission dialog
  bool shouldShowPermissionDialog(LocationPermissionStatus status) {
    // return status == LocationPermissionStatus.denied ||
    return status == LocationPermissionStatus.deniedForever;
  }

  Future<void> openAppSettings() async {
    await perm.openAppSettings();
  }
}
