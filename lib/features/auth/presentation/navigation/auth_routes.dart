import 'package:flutter/material.dart';
import 'package:salesforce/app/route_slide_transaction.dart';
import 'package:salesforce/features/auth/presentation/pages/first_download/first_download_screen.dart';
import 'package:salesforce/features/auth/presentation/pages/forget_password/forget_password_screen.dart';
import 'package:salesforce/features/auth/presentation/pages/login/login_screen.dart';
import 'package:salesforce/features/auth/presentation/pages/verify_phone_number/verify_phone_number_screen.dart';

Route<dynamic>? authOnGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.routeName:
      return PageRouteBuilder(
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return LoginScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case VerifyPhoneNumberScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return VerifyPhoneNumberScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case ForgetPasswordScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const ForgetPasswordScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case FirstDownloadScreen.routeName:
      return MaterialPageRoute(builder: (_) => const FirstDownloadScreen());

    default:
      return null;
  }
}
