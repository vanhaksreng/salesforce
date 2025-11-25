import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/features/auth/presentation/navigation/auth_routes.dart';
import 'package:salesforce/features/auth/presentation/pages/loggedin_history/loggedin_history_screen.dart';
import 'package:salesforce/features/auth/presentation/pages/login/login_screen.dart';
import 'package:salesforce/features/auth/presentation/pages/starter_screen/scanner_screen.dart';
import 'package:salesforce/features/auth/presentation/pages/starter_screen/starter_screen.dart';
import 'package:salesforce/features/main_tap_screen.dart';
import 'package:salesforce/features/more/presentation/navigation/more_routes.dart';
import 'package:salesforce/features/report/presentation/navigation/report_routes.dart';
import 'package:salesforce/features/stock/presentation/navigation/stock_routes.dart';
import 'package:salesforce/features/tasks/presentation/navigation/task_routes.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/splash/splash_screen.dart';

Route<dynamic>? appRouter(RouteSettings settings) {
  final auth = getAuth();
  final initSync = getInitAppStage();

  // print(settings.name);
  // print(initSync.isSyncSetting);
  // print(auth?.expired);

  if (auth == null) {
    if (settings.name == ScannerScreen.routeName) {
      return MaterialPageRoute(builder: (_) => const ScannerScreen());
    } else if (settings.name != LoginScreen.routeName) {
      return MaterialPageRoute(builder: (_) => const StarterScreen());
    }
  }

  if (settings.name == LoginScreen.routeName) {
    return MaterialPageRoute(builder: (_) => LoginScreen());
  }

  if (settings.name == StarterScreen.routeName) {
    return MaterialPageRoute(builder: (_) => const StarterScreen());
  }

  if (settings.name == ScannerScreen.routeName) {
    return MaterialPageRoute(builder: (_) => const ScannerScreen());
  }

  if (auth != null &&
      auth.expired == kStatusYes &&
      settings.name == LoginScreen.routeName) {
    return MaterialPageRoute(builder: (_) => const LoginScreen());
  }

  if (auth != null && auth.expired == kStatusYes) {
    return MaterialPageRoute(
      builder: (_) {
        return const LoginScreen();
      },
    );
  }

  final authRoutes = authOnGenerateRoute(settings);
  if (authRoutes != null) return authRoutes;

  final moreRoutes = moreOnGenerateRoute(settings);
  if (moreRoutes != null) return moreRoutes;

  final reportRoutes = reportOnGenerateRoute(settings);
  if (reportRoutes != null) return reportRoutes;

  final taskRoute = tasksOnGenerateRoute(settings);
  if (taskRoute != null) return taskRoute;

  final stockRoutes = stockOnGenerateRoute(settings);
  if (stockRoutes != null) return stockRoutes;

  if (auth != null && settings.name == "/") {
    if (initSync.isSyncSetting == false) {
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    }

    return MaterialPageRoute(builder: (_) => MainTapScreen());
  }

  return MaterialPageRoute(
    builder: (_) => Scaffold(
      body: Center(child: Text('No route defined for ${settings.name}')),
    ),
  );
}
