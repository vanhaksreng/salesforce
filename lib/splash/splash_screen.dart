import 'package:flutter/material.dart';
import 'package:salesforce/core/domain/entities/init_app_stage.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/features/main_tap_screen.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/splash/splash_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  static const String routeName = "splashScreen";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _cubit = SplashCubit();

  @override
  void initState() {
    super.initState();
    _syncAndNavigate();
  }

  Future<void> _syncAndNavigate() async {
    try {
      if (await _cubit.isConnectedToNetwork()) {
        await _cubit.loadInitialData();
        await Future.delayed(const Duration(milliseconds: 200));
        await _handleDownload();
        await _cubit.getSchedules();
      }

      await setInitAppStage(const InitAppStage(isSyncSetting: true));
      if (mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => MainTapScreen()), (route) => false);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog();
      }
    }
  }

  Future<void> _handleDownload() async {
    try {
      if (!await _cubit.isValidApiSession()) {
        return;
      }

      List<String> tables = ["promotion_type"];

      final filter = tables.map((table) => '"$table"').toList();

      final appSyncLogs = await _cubit.getAppSyncLogs({'tableName': 'IN {${filter.join(",")}}'});

      if (tables.isEmpty) {
        throw GeneralException("Cannot find any table related");
      }

      await _cubit.downloadDatas(appSyncLogs);
    } on Exception {
      //
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Failed'),
        content: const Text('Failed to sync app settings. Continue anyway?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Retry')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => MainTapScreen()),
                (route) => false,
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Syncing app settings...')],
        ),
      ),
    );
  }
}
