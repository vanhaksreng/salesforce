import 'package:flutter/material.dart';
import 'package:salesforce/app/route_slide_transaction.dart';
import 'package:salesforce/features/stock/domain/entities/stock_args.dart';
import 'package:salesforce/features/stock/presentation/pages/stock_request/stock_request_screen.dart';

Route<dynamic>? stockOnGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case StockRequestScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return StockRequestScreen(stockReqArg: settings.arguments as StockRequestArg);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    default:
      return null; // Let the global router handle unknown routes
  }
}
