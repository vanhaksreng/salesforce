import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/core/domain/entities/init_app_stage.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/features/main_tap_screen.dart';
import 'package:salesforce/infrastructure/external_services/location/geolocator_location_service.dart';
import 'package:salesforce/infrastructure/external_services/location/i_location_service.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/splash/splash_cubit.dart';
import 'package:salesforce/injection_container.dart' as di;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = "splashScreen";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _cubit = SplashCubit();
  final appRepo = di.getIt<BaseAppRepository>();
  final ILocationService _location = GeolocatorLocationService();

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    await _cubit.loadCheckInitWithLocationSetting();
    await _syncAndNavigate();
  }

  Future<void> _syncAndNavigate() async {
    try {
      if (await _cubit.isConnectedToNetwork()) {
        await _cubit.loadInitialData();
        await Future.delayed(const Duration(milliseconds: 100));
        await _cubit.getSchedules();
      }

      try {
        
        if (_cubit.state.isUseGpsTracing) {
          if (!mounted) return;
          final position = await _location.getCurrentLocation(context: context);

          await appRepo.storeLocationOffline(
            LatLng(position.latitude, position.longitude),
          );
        }
      } catch (e) {
        // Log only – app can continue without location
        debugPrint("Location error on splash: $e");
      }

      await setInitAppStage(const InitAppStage(isSyncSetting: true));

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainTapScreen()),
        (route) => false,
      );
    } catch (e) {
      // if (!mounted) return;
      // _showErrorDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LoadingPageWidget(label: "Syncing app settings..."),
    );
  }
}
