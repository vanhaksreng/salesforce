import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salesforce/data/services/onesignal_notification.dart';
import 'package:salesforce/app/app_router.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/infrastructure/services/location_service.dart';
import 'package:salesforce/localization/locals_delegate.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_themes.dart';
import 'injection_container.dart' as di;

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await _initializeApp();

    await di.getItInit();

    OneSignalNotificationService.initialize();

    runApp(const TradeB2b());
  } catch (e) {
    debugPrint('Initialization error: $e');
  }
}

Future<void> _initializeApp() async {
  await Future.wait([_configureSystemUI()]);
}

Future<void> _configureSystemUI() async {
  if (Platform.isIOS) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
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
  final LocationService locationService = LocationService();

  @override
  void initState() {
    super.initState();

    final auth = di.getAuth();
    if (auth != null) {
      locationService.startSmartTracking();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: kAppScaffoldMsgKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
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
        SizeConfig().init(context);

        return child ?? const SizedBox.shrink();
      },
      navigatorKey: kAppNavigatorKey,
      locale: Locale(language, languageCode),
    );
  }
}
