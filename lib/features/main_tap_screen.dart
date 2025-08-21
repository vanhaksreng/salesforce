import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/app/custom_bottom_navigation_bar.dart';
import 'package:salesforce/app/navigation_item.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/features/more/more_main_page.dart';
import 'package:salesforce/features/more/more_main_page_cubit.dart';
import 'package:salesforce/features/notification/notification_screen.dart';
import 'package:salesforce/features/report/main_page_report_screen.dart';
import 'package:salesforce/features/stock/main_page_stock_screen.dart';
import 'package:salesforce/features/tasks/tasks_main_cubit.dart';
import 'package:salesforce/features/tasks/tasks_main_screen.dart';
import 'package:salesforce/infrastructure/external_services/location/geolocator_location_service.dart';
import 'package:salesforce/infrastructure/external_services/unified_location_manager.dart';
import 'package:salesforce/infrastructure/gps/gps_service_impl.dart';
import 'package:salesforce/infrastructure/heartbeat/heartbeat_service_impl.dart';
import 'package:salesforce/injection_container.dart' as di;

class MainTapScreen extends StatefulWidget {
  const MainTapScreen({super.key});

  static String routeName = "homeScreen";

  @override
  State<MainTapScreen> createState() => _MainTapScreenState();
}

class _MainTapScreenState extends State<MainTapScreen>
    with WidgetsBindingObserver {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  final _appRepo = di.getIt<BaseAppRepository>();
  final _locationManager = UnifiedLocationManager.instance;
  final _geolocation = GeolocatorLocationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeLocationServices();
  }

  @override
  void dispose() {
    _locationManager.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final isActive = state == AppLifecycleState.resumed;
    _locationManager.setAppLifecycleState(isActive);

    if (state == AppLifecycleState.detached) {
      _handleAppTerminating();
    }
  }

  Future<void> _initializeLocationServices() async {
    try {
      // Initialize the unified location manager
      await _locationManager.initialize(
        appRepo: _appRepo,
        gpsService: GpsServiceImpl(_appRepo),
        heartbeatService: HeartbeatServiceImpl(_appRepo),
      );

      // Check permissions and show dialog if needed
      final locationStatus = await _geolocation.checkPermission();
      if (!mounted) return;

      if (_locationManager.shouldShowPermissionDialog(locationStatus)) {
        _showPermissionDialog();
        return;
      }

      await _setupLocationTracking();
      await _locationManager.syncPendingLocations();
    } catch (e) {
      Logger.log("Failed to initialize location services: $e");
    }
  }

  Future<void> _setupLocationTracking() async {
    try {
      final permissionsGranted = await _locationManager.requestAllPermissions();

      if (permissionsGranted) {
        final trackingStarted = await _locationManager.startLocationTracking();

        if (trackingStarted) {
          final auth = di.getAuth();
          if (auth != null) {
            await _locationManager.syncAllData(auth: auth);
          }
        }
      } else {
        Logger.log("Location permissions not granted");
      }
    } catch (e) {
      Logger.log("Failed to setup location tracking: $e");
    }
  }

  void _showPermissionDialog() {
    Helpers.showDialogAction(
      context,
      labelAction: "Location Access Required",
      subtitle:
          "As required by your company, the app needs access to your current location. "
          "This is essential for tracking your check-in and check-out activities at customer sites.",
      confirmText: "Go to Settings",
      confirm: () async {
        await _locationManager.openAppSettings();
        if (!mounted) return;
        Navigator.pop(context);
      },
      cancelText: "Not Now",
    );
  }

  Future<void> _handleAppTerminating() async {
    try {
      final auth = di.getAuth();
      if (auth != null) {
        await _locationManager.syncPendingLocations();
        await _locationManager.syncAllData(auth: auth);
      }

      // Switch to background tracking if permission available
      if (_locationManager.hasBackgroundPermission &&
          _locationManager.isTracking) {
        // The unified manager will handle this in setAppLifecycleState
        Logger.log("App terminating - background tracking maintained");
      }
    } catch (e) {
      Logger.log("Error handling app termination: $e");
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
      // persistentFooterButtons: [
      //   TextButton(
      //     onPressed: () async {
      //       await _locationManager.syncPendingLocations();
      //     },
      //     child: Text("Click Me"),
      //   ),
      // ],
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
