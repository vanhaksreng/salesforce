import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/app/custom_bottom_navigation_bar.dart';
import 'package:salesforce/app/navigation_item.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/features/more/more_main_page.dart';
import 'package:salesforce/features/more/more_main_page_cubit.dart';
import 'package:salesforce/features/notification/notification_screen.dart';
import 'package:salesforce/features/report/main_page_report_screen.dart';
import 'package:salesforce/features/stock/main_page_stock_screen.dart';
import 'package:salesforce/features/tasks/tasks_main_cubit.dart';
import 'package:salesforce/features/tasks/tasks_main_screen.dart';
import 'package:salesforce/infrastructure/external_services/location/geolocator_location_service.dart';
import 'package:salesforce/infrastructure/external_services/location/location_permission_status.dart';
import 'package:salesforce/injection_container.dart';

class MainTapScreen extends StatefulWidget {
  const MainTapScreen({super.key});

  static const String routeName = "homeScreen";

  @override
  State<MainTapScreen> createState() => _MainTapScreenState();
}

class _MainTapScreenState extends State<MainTapScreen>
    with WidgetsBindingObserver {
  static const Duration _syncInterval = Duration(seconds: 60);
  static const Duration _heartbeatInterval = Duration(seconds: 90);
  static const double _locationAccuracyThreshold = 10.0;
  static const int _distanceFilter = 3;

  // State variables
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  late final BaseAppRepository _appRepo;
  late final GeolocatorLocationService _geolocation;

  Timer? _syncTimer;
  Timer? _heartbeatTimer;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
    _initializeApp();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _cleanupResources();
    _selectedIndex.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _pauseBackgroundTasks();
        break;
      case AppLifecycleState.resumed:
        _resumeBackgroundTasks();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _initializeServices() {
    _appRepo = getIt<BaseAppRepository>();
    _geolocation = GeolocatorLocationService();
  }

  Future<void> _initializeApp() async {
    try {
      await Future.wait([_syncHeartbeat(), _syncGpsData()]);

      await _startPeriodicSync();
      await _requestLocationPermissionAndStartTracking();
    } catch (e) {
      Logger.log("Error during app initialization: $e");
    }
  }

  Future<void> _requestLocationPermissionAndStartTracking() async {
    try {
      final status = await _geolocation.requestPermission();
      if (status != LocationPermissionStatus.denied) {
        await _startLocationTracking();
      } else {
        Logger.log("Location permission denied");
      }
    } catch (e) {
      Logger.log("Error requesting location permission: $e");
    }
  }

  Future<void> _startPeriodicSync() async {
    if (_isDisposed) return;

    _stopAllTimers();

    final auth = getAuth();
    if (auth == null) {
      Logger.log("No authentication available for periodic sync");
      return;
    }

    _syncTimer = Timer.periodic(
      _syncInterval,
      (_) => _performSyncTask(_syncGpsData),
    );
    _heartbeatTimer = Timer.periodic(
      _heartbeatInterval,
      (_) => _performSyncTask(_syncHeartbeat),
    );

    Logger.log("Periodic sync started");
  }

  Future<void> _performSyncTask(Future<void> Function() task) async {
    if (_isDisposed) return;

    final auth = getAuth();
    if (auth != null) {
      try {
        await task();
      } catch (e) {
        Logger.log("Sync task failed: $e");
      }
    }
  }

  Future<void> _startLocationTracking() async {
    if (_isDisposed) return;

    try {
      _geolocation.stopTracking();

      _geolocation.startContinuousLocationTracking(
        distanceFilter: _distanceFilter,
        onData: _handleLocationUpdate,
        maxAcceptableAccuracy: _locationAccuracyThreshold,
      );

      Logger.log("Location tracking started");
    } catch (e) {
      Logger.log("Error starting location tracking: $e");
    }
  }

  Future<void> _handleLocationUpdate(Position position) async {
    if (_isDisposed) return;

    if (position.accuracy > _locationAccuracyThreshold) {
      Logger.log("Location accuracy too low: ${position.accuracy}");
      return;
    }

    Logger.log(
      "Location updated - lat: ${position.latitude.toStringAsFixed(6)}, "
      "lng: ${position.longitude.toStringAsFixed(6)}, "
      "accuracy: ${position.accuracy.toStringAsFixed(1)}m",
    );

    try {
      await _appRepo.storeLocationOffline(
        LatLng(position.latitude, position.longitude),
      );
    } catch (e) {
      Logger.log("Error storing location offline: $e");
    }
  }

  Future<void> _syncGpsData() async {
    if (_isDisposed) return;

    try {
      await _appRepo.syncOfflineLocationToBackend();
      Logger.log("GPS data synced successfully");
    } catch (e) {
      Logger.log("GPS sync failed: $e");
      // Consider implementing retry logic here
    }
  }

  Future<void> _syncHeartbeat() async {
    if (_isDisposed) return;

    try {
      final auth = getAuth();
      if (auth?.token == null) {
        Logger.log("No auth token available for heartbeat");
        return;
      }

      await _appRepo.heartbeatStatus(
        params: {
          'rtype': 'heartbeat',
          'status': 'online',
          'token': auth!.token,
        },
      );

      Logger.log("Heartbeat sent successfully");
    } catch (e) {
      Logger.log("Heartbeat failed: $e");
    }
  }

  void _stopAllTimers() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _pauseBackgroundTasks() {
    _stopAllTimers();
    _geolocation.stopTracking();
    Logger.log("Background tasks paused");
  }

  Future<void> _resumeBackgroundTasks() async {
    await _startPeriodicSync();
    // await _startLocationTracking();
    Logger.log("Background tasks resumed");
  }

  void _cleanupResources() {
    _stopAllTimers();
    _geolocation.stopTracking();
  }

  List<NavigationItem> get _navigationItems => [
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
      label: 'Stock',
      screen: MainPageStockScreen(),
    ),
    const NavigationItem(
      icon: Icons.receipt_long_outlined,
      label: 'Report',
      screen: MainPageReportScreen(),
    ),
    const NavigationItem(
      icon: Icons.notifications_active_outlined,
      label: 'Reminders',
      screen: NotificationScreen(),
    ),
    NavigationItem(
      icon: Icons.grid_view_outlined,
      label: 'More',
      screen: BlocProvider(
        create: (context) => MoreMainPageCubit(),
        child: const MoreMainPage(),
      ),
    ),
  ];

  void _onNavigationItemTapped(int index) {
    if (index >= 0 && index < _navigationItems.length) {
      _selectedIndex.value = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, index, _) {
          // Ensure index is within bounds
          final safeIndex = index.clamp(0, _navigationItems.length - 1);
          return KeyedSubtree(
            key: ValueKey(safeIndex),
            child: _navigationItems[safeIndex].screen,
          );
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, index, _) {
          return CustomBottomNavigationBar(
            currentIndex: index,
            onTap: _onNavigationItemTapped,
            navigationItems: _navigationItems,
          );
        },
      ),
    );
  }
}
