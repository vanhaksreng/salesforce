import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salesforce/crash_report.dart';
import 'package:salesforce/features/worker_manager/auto_upload_manager.dart';
import 'package:salesforce/data/services/onesignal_notification.dart';
import 'package:salesforce/app/app_router.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/localization/locals_delegate.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_themes.dart';
import 'package:workmanager/workmanager.dart';
import 'injection_container.dart' as di;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      await di.getItInit();

      return await AutoUploadManager.handleTask(taskName, inputData);
    } catch (e) {
      return Future.value(false);
    }
  });
}

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Workmanager().initialize(callbackDispatcher);
      // HttpOverrides.global = MyHttpOverrides();
      await AutoUploadManager.initialize();
      await _initializeApp();
      await di.getItInit();

      runApp(const TradeB2b());

      OneSignalNotificationService.initialize();

      // CrashReport.sendCrashReport(
      //   "Testing",

      // );
    },
    (error, stackTrace) {
      debugPrint('Initialization error: $error');
      CrashReport.sendCrashReport(
        error.toString(),
        stackTrace: stackTrace.toString(),
      );
    },
  );
}

Future<void> _initializeApp() async {
  await Future.wait([_configureSystemUI()]);
}

Future<void> _configureSystemUI() async {
  if (Platform.isIOS) {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
}

class TradeB2b extends StatefulWidget {
  const TradeB2b({super.key});

  @override
  State<TradeB2b> createState() => _TradeB2bState();
}

class _TradeB2bState extends State<TradeB2b> {
  final language = "en";
  final String languageCode = "EN";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: kAppScaffoldMsgKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorObservers: [routeObserver],
      localizationsDelegates: [
        LocalsDelegate(),
        // GlobalMaterialLocalizations.delegate,
        // GlobalWidgetsLocalizations.delegate,
        // GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'EN'), Locale('km', 'KH')],
      onGenerateRoute: appRouter,
      builder: (context, child) {
        Trans().init(context);
        // SizeConfig().init(context);

        return child ?? const SizedBox.shrink();
      },
      navigatorKey: kAppNavigatorKey,
      locale: Locale(language, languageCode),
    );
  }
}

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }
