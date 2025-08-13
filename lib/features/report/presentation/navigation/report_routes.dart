import 'package:flutter/material.dart';
import 'package:salesforce/app/route_slide_transaction.dart';
import 'package:salesforce/features/report/presentation/pages/build_selected_saleperson/build_selected_saleperson.dart';
import 'package:salesforce/features/report/presentation/pages/customer_balance_report/customer_balance_report_screen.dart';
import 'package:salesforce/features/report/presentation/pages/daily_sale_summary_report/daily_sale_summary_report_screen.dart';
import 'package:salesforce/features/report/presentation/pages/item_inventory_report/item_inventory_report_screen.dart';
import 'package:salesforce/features/report/presentation/pages/item_redemption_by_salesperson_report/item_redemption_by_salesperson_report_screen.dart';
import 'package:salesforce/features/report/presentation/pages/so_outstanding_report/so_outstanding_report_screen.dart';
import 'package:salesforce/features/report/presentation/pages/stock_request_details_report/stock_request_details_report_screen.dart';
import 'package:salesforce/features/report/presentation/pages/stock_request_report/stock_request_report_screen.dart';

Route<dynamic>? reportOnGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case SoOutstandingReportScreen.routeName:
      return PageRouteBuilder(
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const SoOutstandingReportScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case DailySaleSummaryReportScreen.routeName:
      return PageRouteBuilder(
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const DailySaleSummaryReportScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case ItemInventoryReportScreen.routeName:
      return PageRouteBuilder(
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const ItemInventoryReportScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case CustomerBalanceReportScreen.routeName:
      return PageRouteBuilder(
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const CustomerBalanceReportScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case BuildSelectedSaleperson.routeName:
      return PageRouteBuilder(
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return BuildSelectedSaleperson(arg: settings.arguments as BuildSelectedSalepersonArg);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case StockRequestReportScreen.routeName:
      return PageRouteBuilder(
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const StockRequestReportScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case StockRequestDetailsReportScreen.routeName:
      return PageRouteBuilder(
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return StockRequestDetailsReportScreen(args: settings.arguments as StockRequestArg);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case ItemRedemptionBySalespersonReportScreen.routeName:
      return PageRouteBuilder(
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const ItemRedemptionBySalespersonReportScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    default:
      return null;
  }
}
