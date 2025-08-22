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

  static String routeName = "homeScreen";

  @override
  State<MainTapScreen> createState() => _MainTapScreenState();
}

class _MainTapScreenState extends State<MainTapScreen> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  final _appRepo = getIt<BaseAppRepository>();
  final _geolocation = GeolocatorLocationService();

  Timer? _syncTimer;
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _stopAllTimers() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _init() async {
    await _syncHeartbeat();
    await _syncGpsData();

    await _startPeriodicSync();

    final status = await _geolocation.requestPermission();
    if (status != LocationPermissionStatus.denied) {
      _startTracking();
    }
  }

  Future<void> _startPeriodicSync() async {
    _stopAllTimers();
    final auth = getAuth();

    // Sync GPS data every 60 seconds
    _syncTimer = Timer.periodic(const Duration(seconds: 60), (_) async {
      if (auth != null) {
        await _syncGpsData();
      }
    });

    // Sync heartbeat every 90 seconds
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 90), (_) async {
      if (auth != null) {
        await _syncHeartbeat();
      }
    });
  }

  void _startTracking() {
    _geolocation.stopTracking();

    _geolocation.startContinuousLocationTracking(
      distanceFilter: 3,
      onLocationUpdate: (Position position) async {
        if (position.accuracy > 10) {
          return;
        }

        Logger.log(
          "latitude:${position.latitude}, longitude:${position.longitude}, accuracy:${position.accuracy} ",
        );

        await _appRepo.storeLocationOffline(
          LatLng(position.latitude, position.longitude),
        );
      },
    );
  }

  Future<void> _syncGpsData() async {
    try {
      await _appRepo.syncOfflineLocationToBackend();
      Logger.log("GPS data synced to backend");
    } catch (e) {
      Logger.log("Error syncing GPS data: $e");
    }
  }

  Future<void> _syncHeartbeat() async {
    try {
      final auth = getAuth();
      await _appRepo.heartbeatStatus(
        params: {
          'rtype': 'heartbeat',
          'status': 'online',
          'token': auth?.token ?? "",
        },
      );

      Logger.log("Heartbeat synced");
    } catch (e) {
      Logger.log("Error syncing heartbeat: $e");
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
