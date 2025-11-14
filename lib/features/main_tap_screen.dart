import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/app/custom_bottom_navigation_bar.dart';
import 'package:salesforce/app/navigation_item.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/features/more/more_main_page.dart';
import 'package:salesforce/features/more/more_main_page_cubit.dart';
import 'package:salesforce/features/notification/notification_screen.dart';
import 'package:salesforce/features/report/main_page_report_screen.dart';
import 'package:salesforce/features/stock/main_page_stock_screen.dart';
import 'package:salesforce/features/tasks/tasks_main_cubit.dart';
import 'package:salesforce/features/tasks/tasks_main_screen.dart';
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

  bool _hasBackgroundPermission = false;
  Map<String, dynamic>? latestLocation;
  Timer? syncTimer;
  Timer? heartbeatTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initBGTasks();
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

    await appRepo.syncOfflineLocationToBackend();
    await appRepo.heartbeatStatus(
      params: {'status': 'online', 'rtype': 'heartbeat'},
    );

    syncTimer = Timer.periodic(Duration(seconds: 60), (timer) async {
      if (latestLocation != null) {
        try {
          await appRepo.syncOfflineLocationToBackend();
          Logger.log(
            "Synced to backend: ${latestLocation!['latitude']}, ${latestLocation!['longitude']}",
          );
        } catch (e) {
          Logger.log("Error syncing to backend: $e");
        }
      }
    });

    heartbeatTimer = Timer.periodic(Duration(seconds: 90), (timer) async {
      if (latestLocation != null) {
        try {
          await appRepo.heartbeatStatus(
            params: {'status': 'online', 'rtype': 'heartbeat'},
          );
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
        _handleAppResumed();
        break;

      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _handleAppBackground();
        break;

      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _handleAppResumed() async {
    _startTimers();
  }

  Future<void> _handleAppBackground() async {
    _stopTimers();
  }

  // MARK: - Enhanced Background Task Initialization
  Future<void> _initBGTasks() async {
    // svc.onLocation.listen((loc) async {
    //   try {
    //     await appRepo.storeLocationOffline(
    //       LatLng(loc['latitude'], loc['longitude']),
    //     );
    //   } catch (e) {
    //     Logger.log("Error processing GPS location: $e");
    //   }
    // });

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
          _handleSyncLocations(e['data'] ?? []);
          break;
      }
    });

    await _requestPermissions();

    await _startTracking();
  }

  void _handleSyncLocations(List<dynamic> locationData) async {
    String saleCode = await _getCurrentSaleCode();
    if (saleCode.isEmpty) return;

    final gpsRecords = <GpsRouteTracking>[];
    for (var data in locationData) {
      final record = _createGpsRecord(data, saleCode);
      if (record != null) {
        gpsRecords.add(record);
      }
    }

    if (gpsRecords.isNotEmpty) {
      await appRepo.storeGps(gpsRecords);
      await appRepo.syncOfflineLocationToBackend();
    }
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

      if (!fgGranted) {
        Logger.log("Foreground location permission denied");
        return;
      }

      final bgGranted = await svc.requestPermissions(
        LocationTrackingMode.background,
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
        mode = LocationTrackingMode.background;
      } else if (perm['canTrackForeground'] == true) {
        mode = LocationTrackingMode.foreground;
      } else {
        Logger.log("No location permissions available");
        return;
      }

      final success = await svc.startTracking(mode: mode);

      if (!success) {
        Logger.log("Failed to start GPS tracking");
      }
    } catch (e) {
      Logger.log("Start tracking failed: $e");
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

  Future<String> _getCurrentSaleCode() async {
    final auth = di.getAuth();

    if (auth?.salepersonCode.isNotEmpty == true) {
      return auth?.salepersonCode ?? "";
    }

    // Fallback to user setup
    final response = await appRepo.getUserSetup();
    return response.fold((l) => "", (r) {
      return r?.salespersonCode ?? "";
    });
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
