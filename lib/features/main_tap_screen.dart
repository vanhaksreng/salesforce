import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/app/custom_bottom_navigation_bar.dart';
import 'package:salesforce/app/navigation_item.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/features/more/more_main_page.dart';
import 'package:salesforce/features/more/more_main_page_cubit.dart';
import 'package:salesforce/features/notification/notification_screen.dart';
import 'package:salesforce/features/report/main_page_report_screen.dart';
import 'package:salesforce/features/stock/main_page_stock_screen.dart';
import 'package:salesforce/features/tasks/tasks_main_cubit.dart';
import 'package:salesforce/features/tasks/tasks_main_screen.dart';
import 'package:salesforce/infrastructure/gps/gps_service.dart';
import 'package:salesforce/infrastructure/gps/gps_service_impl.dart';
import 'package:salesforce/infrastructure/heartbeat/heartbeat_service.dart';
import 'package:salesforce/infrastructure/heartbeat/heartbeat_service_impl.dart';
import 'package:salesforce/infrastructure/services/location_service.dart';
import 'package:salesforce/injection_container.dart' as di;
import 'package:salesforce/realm/scheme/general_schemas.dart';

class MainTapScreen extends StatefulWidget {
  const MainTapScreen({super.key});

  static String routeName = "homeScreen";

  @override
  State<MainTapScreen> createState() => _MainTapScreenState();
}

class _MainTapScreenState extends State<MainTapScreen>
    with WidgetsBindingObserver {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  final appRepo = di.getIt<BaseAppRepository>();
  final svc = LocationService.instance;
  late IGpsService? gpsService;
  late IHeartbeatService? heartbeatService;

  bool _hasBackgroundPermission = false;
  Map<String, dynamic>? latestLocation;
  Timer? syncTimer;
  Timer? heartbeatTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final isActive =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

    LocationService.instance.setAppActive(isActive);
    gpsService = GpsServiceImpl(appRepo);
    heartbeatService = HeartbeatServiceImpl(appRepo);

    _initBGTasks();

    importBufferedToRealm();

    _startTimers();
  }

  @override
  void dispose() {
    syncTimer?.cancel();
    syncTimer = null;
    heartbeatTimer?.cancel();
    heartbeatTimer = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startTimers() async {
    final auth = di.getAuth();
    if (auth == null) {
      return;
    }

    await gpsService?.syncToBackend(auth: auth);
    await heartbeatService?.execute(auth: auth);

    // Start periodic sync (every 60 seconds)
    syncTimer = Timer.periodic(Duration(seconds: 60), (timer) async {
      if (latestLocation != null) {
        try {
          await gpsService?.syncToBackend(auth: auth);
          Logger.log(
            "Synced to backend: ${latestLocation!['latitude']}, ${latestLocation!['longitude']}",
          );
        } catch (e) {
          Logger.log("Error syncing to backend: $e");
        }
      }
    });

    // Start periodic heartbeat sync (every 60 seconds)
    heartbeatTimer = Timer.periodic(Duration(seconds: 90), (timer) async {
      if (latestLocation != null) {
        try {
          await heartbeatService?.execute(auth: auth);
        } catch (e) {
          Logger.log("Error syncing to backend: $e");
        }
      }
    });
  }

  void _stopTimers() {
    syncTimer?.cancel();
    syncTimer = null;
    heartbeatTimer?.cancel();
    heartbeatTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        LocationService.instance.setAppActive(true);
        _handleAppResumed();
        break;

      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        LocationService.instance.setAppActive(false);
        _handleAppBackground();
        break;

      case AppLifecycleState.detached:
        LocationService.instance.setAppActive(false);
        _handleAppTerminating();
        break;

      case AppLifecycleState.hidden:
        LocationService.instance.setAppActive(false);
        break;
    }
  }

  Future<void> _handleAppResumed() async {
    await importBufferedToRealm();
    _startTimers();
  }

  Future<void> _handleAppBackground() async {
    _stopTimers();
  }

  Future<void> _handleAppTerminating() async {
    if (_hasBackgroundPermission && svc.isTracking) {
      await svc.startTracking(
        mode: LocationTrackingMode.significant,
        distanceFilter: 50.0,
      );
    }
  }

  Future<void> importBufferedToRealm() async {
    try {
      final f = await svc.bufferFile();
      if (!await f.exists()) {
        return;
      }

      final lines = await f.readAsLines();
      if (lines.isEmpty) {
        await f.delete();
        return;
      }

      final auth = di.getAuth();
      if (auth == null) {
        return;
      }

      late String saleCode = auth.salepersonCode;
      if (saleCode.isEmpty) {
        await appRepo.getUserSetup().then((response) {
          response.fold((l) => null, (r) {
            saleCode = r?.salespersonCode ?? "";
          });
        });
      }

      final List<GpsRouteTracking> gpsRecords = [];
      int skippedRecords = 0;

      for (int i = 0; i < lines.length; i++) {
        try {
          final Map m = jsonDecode(lines[i]);

          if (!m.containsKey('latitude') ||
              !m.containsKey('longitude') ||
              !m.containsKey('timestamp')) {
            skippedRecords++;
            continue;
          }

          final line = GpsRouteTracking(
            saleCode,
            (m['latitude'] as num).toDouble(),
            (m['longitude'] as num).toDouble(),
            DateTime.parse(m['timestamp'] as String).toDateString(),
            DateTime.parse(m['timestamp'] as String).toDateTimeString(),
            isSync: "No",
          );

          gpsRecords.add(line);
        } catch (e) {
          Logger.log("Failed to parse GPS record at line ${i + 1}: $e");
          skippedRecords++;
        }
      }

      if (gpsRecords.isNotEmpty) {
        await gpsService?.storeGps(records: gpsRecords);
        await gpsService?.syncToBackend(auth: auth);

        if (skippedRecords > 0) {
          Logger.log("Skipped $skippedRecords invalid records");
        }
      }

      await f.delete();
    } catch (e) {
      Logger.log("importBufferedToRealm failed: $e");
    }
  }

  // MARK: - Enhanced Background Task Initialization
  Future<void> _initBGTasks() async {
    // Enhanced location listener with better error handling
    svc.onLocation.listen((loc) async {
      try {
        await gpsService?.execute(
          latlng: LatLng(loc['latitude'], loc['longitude']),
        );
      } catch (e) {
        Logger.log("Error processing GPS location: $e");
      }
    });

    // Enhanced event listener
    svc.onEvent.listen((e) {
      final type = e['type'] ?? 'unknown';
      final message = e['message'] ?? '';

      switch (type) {
        case 'error':
          _handleGpsError(message);
          break;
        case 'permissionChanged':
          _handlePermissionChange(e);
          break;
        case 'syncLocations':
          _handleSyncLocations(e['data']);
          break;
      }
    });

    await _requestPermissions();
    await _startTracking();
  }

  void _handleSyncLocations(List<dynamic> data) {
    Logger.log("handleSyncLocations $data");
  }

  void _handleGpsError(String error) {
    if (error.contains('permission')) {
      Logger.log("GPS permission error - may need user intervention");
    } else if (error.contains('location')) {
      Logger.log("GPS location error - continuing with existing setup");
    }
  }

  void _handlePermissionChange(Map<String, dynamic>? data) async {
    if (data != null &&
        ([
          'authorizedAlways',
          'authorizedWhenInUse',
        ].contains(data['status']))) {
      Logger.log(data);
      if (data['status'] == "authorizedWhenInUse") {
        await _requestPermissions();
      }

      _hasBackgroundPermission = true;

      if (!svc.isTracking) {
        _startTracking();
      }
    }
  }

  Future<void> _requestPermissions() async {
    try {
      final fgGranted = await svc.requestPermissions(
        LocationTrackingMode.foreground,
      );

      Logger.log("requestPermissions : $fgGranted");

      if (!fgGranted) {
        Logger.log("Foreground location permission denied");
        return;
      }

      final bgGranted = await svc.requestPermissions(
        LocationTrackingMode.periodic,
      );

      _hasBackgroundPermission = bgGranted;

      if (bgGranted) {
        Logger.log("Background location permission granted");
      } else {
        Logger.log("Background permission denied - using foreground only");
      }
    } catch (e) {
      Logger.log("Permission request failed: $e");
    }
  }

  Future<void> _startTracking() async {
    try {
      final perm = await svc.checkPermissions();

      _hasBackgroundPermission = perm['background'] == true;

      LocationTrackingMode mode;

      if (_hasBackgroundPermission) {
        mode = LocationTrackingMode.periodic;
      } else if (perm['canTrackForeground'] == true) {
        mode = LocationTrackingMode.foreground;
      } else {
        Logger.log("No location permissions available");
        return;
      }

      final success = await svc.startTracking(
        mode: mode,
        distanceFilter: svc.getDistanceFilterForMode(mode),
      );

      if (!success) {
        Logger.log("Failed to start GPS tracking");
      }
    } catch (e) {
      Logger.log("Start tracking failed: $e");
    }
  }

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.calendar_month_outlined,
      label: 'Visit',
      screen: BlocProvider(
        create: (context) => TasksMainCubit(),
        child: const TasksMainScreen(),
      ),
    ),
    const NavigationItem(
      icon: Icons.category_outlined,
      label: 'stock',
      screen: MainPageStockScreen(),
    ),
    const NavigationItem(
      icon: Icons.receipt_long_outlined,
      label: 'report',
      screen: MainPageReportScreen(),
    ),
    const NavigationItem(
      icon: Icons.notifications_active_outlined,
      label: 'Reminders',
      screen: NotificationScreen(),
    ),
    NavigationItem(
      icon: Icons.grid_view_outlined,
      label: 'more',
      screen: BlocProvider(
        create: (context) => MoreMainPageCubit(),
        child: const MoreMainPage(),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, index, _) {
          return KeyedSubtree(
            key: ValueKey(index),
            child: _navigationItems[index].screen,
          );
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, index, _) {
          return CustomBottomNavigationBar(
            currentIndex: index,
            onTap: (newIndex) => _selectedIndex.value = newIndex,
            navigationItems: _navigationItems,
          );
        },
      ),
    );
  }
}
