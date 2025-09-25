import 'package:flutter/material.dart';
import 'package:salesforce/app/route_slide_transaction.dart';
import 'package:salesforce/features/tasks/domain/entities/checkout_arg.dart';
import 'package:salesforce/features/tasks/domain/entities/sale_person_gps_model.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/add_schedule/add_schedule_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/barcode_scanner_page.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_item_competitor_stock_form.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_stock_submit_preview/check_stock_submit_preview_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkin_out/checkin_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_stock_form_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_stock_submit_preview_competitor_item/check_stock_submit_preview_competitor_item_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/collections/collections_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/competitor_promotion/competitor_promotion_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/competitor_promotion_line/competitor_promotion_line_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/customer_address/customer_address_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/customer_schedule_map/customer_schedule_map_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/detail_collections/detail_collections_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/distributor/distributor_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/group_screen_filter_item/group_screen_filter_item.dart';
import 'package:salesforce/features/tasks/presentation/pages/item_merchandising/item_merchandising_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/item_posm/item_pom_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/item_prize_redemption/item_prize_redemption_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/payment_screen/payment_screen_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/payment_term/payment_term_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/posm_and_merchanding_competitor/posm_and_merchanding_competior_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/posm_merchanding_preview/posm_merchanding_preview_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/process/process_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/add_card_preview/add_cart_preview_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/item_promotion_form/item_promotion_form_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/sale_checkout/sale_checkout_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/sale_form/sale_form_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/sales_person_map/sales_person_map_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/schedule_history/schedule_history_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/tabbar_items/check_stock_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/tabbar_items/sales_item_screen.dart';
import 'package:salesforce/features/tasks/tasks_main_screen.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

Route<dynamic>? tasksOnGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case TasksMainScreen.routeName:
      return PageRouteBuilder(
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const TasksMainScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 0, end: 1);
        },
      );

    case CustomerScheduleMapScreen.routeName:
      return PageRouteBuilder(
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return CustomerScheduleMapScreen(isMore: settings.arguments as bool);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 0, end: 1);
        },
      );

    case CheckinScreen.routeName:
      return PageRouteBuilder(
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          final args = settings.arguments as SalespersonSchedule;
          return CheckinScreen(schedule: args);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case ProcessScreen.routeName:
      return PageRouteBuilder(
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          final args = settings.arguments as CheckStockArgs;
          return ProcessScreen(args: args);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case CheckStockScreen.routeName:
      return PageRouteBuilder(
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return CheckStockScreen(args: settings.arguments as CheckStockArgs);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case SalesItemScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return SalesItemScreen(args: settings.arguments as SaleItemArgs);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case PosmAndMerchandingCompetitorScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return PosmAndMerchandingCompetitorScreen(
            args: settings.arguments as PosmAndMerchandingCompetitorArg,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child);
        },
      );

    case CheckStockFormScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          final args = settings.arguments as Map<String, dynamic>?;
          return CheckStockFormScreen(
            item: args?["item"] as Item,
            schedule: args?["schedule"] as SalespersonSchedule,
            status: args?["status"] as String,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case ScheduleHistoryScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const ScheduleHistoryScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case AddScheduleScreen.routeName:
      return PageRouteBuilder(
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const AddScheduleScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case ItemPosmScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ItemPosmScreen(
            arg: settings.arguments as ItemPosmAndMerchandiseArg,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child);
        },
      );
    case ItemMerchandisingScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ItemMerchandisingScreen(
            args: settings.arguments as ItemPosmAndMerchandiseArg,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child);
        },
      );

    case SaleFormScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return SaleFormScreen(args: settings.arguments as SaleFormArg);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case CheckStockSubmitPreviewScreen.routeName:
      final args = settings.arguments as CheckStockArgs;

      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return CheckStockSubmitPreviewScreen(arg: args);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case GroupScreenFilterItem.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return GroupScreenFilterItem(
            args: settings.arguments as GroupFilterArgs,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case AddCartPreviewScreen.routeName:
      final args = settings.arguments as Map<String, dynamic>;
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return AddCartPreviewScreen(
            customerNo: args['customerNo'] ?? "",
            scheduleId: args['scheduleId'] ?? "",
            documentType: args['documentType'] ?? "",
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case CheckItemCompetitorStockForm.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return CheckItemCompetitorStockForm(
            arg: settings.arguments as CheckCompititorItemStockArg,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case CheckStockSubmitPreviewCompetitorItemScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          final args = settings.arguments as SalespersonSchedule;
          return CheckStockSubmitPreviewCompetitorItemScreen(schedule: args);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case CompetitorPromotionScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return CompetitorPromotionScreen(
            arg: settings.arguments as ItemPosmAndMerchandiseArg,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case CollectionsScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return CollectionsScreen(arg: settings.arguments as CollectionsArg);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case DetailCollectionsScreen.routeName:
      final args = settings.arguments as Map<String, dynamic>?;
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return DetailCollectionsScreen(
            schedule: args?["schedule"] as SalespersonSchedule,
            customerLedgerEntry:
                args?["customerLedgerEntry"] as CustomerLedgerEntry,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case PaymentScreenScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return PaymentScreenScreen(paymentCode: settings.arguments as String);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case SaleCheckoutScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return SaleCheckoutScreen(arg: settings.arguments as CheckoutArg);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case CustomerAddressScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return CustomerAddressScreen(
            customerNo: settings.arguments as String,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case PaymentTermScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const PaymentTermScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case DistributorScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const DistributorScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case CompetitorPromotionLineScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return CompetitorPromotionLineScreen(
            header: settings.arguments as CompetitorPromtionHeader,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case ItemPromotionFormScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ItemPromotionFormScreen(
            arg: settings.arguments as ItemPromotionFormArg,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case ItemPrizeRedemptionScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ItemPrizeRedemptionScreen(
            arg: settings.arguments as DefaultProcessArgs,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case PosmMerchandingPreviewScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return PosmMerchandingPreviewScreen(
            arg: settings.arguments as ItemPosmAndMerchandiseArg,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case BarcodeScannerPage.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const BarcodeScannerPage();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case SalesPersonMapScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return SalesPersonMapScreen(
            salePersonGps: settings.arguments as List<SalePersonGpsModel>,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    // case StarterScreen.routeName:
    //   return PageRouteBuilder(
    //     pageBuilder: (context, animation, secondaryAnimation) {
    //       return const StarterScreen();
    //     },
    //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //       return RouteST.st(animation, child, begin: 1, end: 0);
    //     },
    //   );
    // case ScannerScreen.routeName:
    //   return PageRouteBuilder(
    //     pageBuilder: (context, animation, secondaryAnimation) {
    //       return const ScannerScreen();
    //     },
    //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //       return RouteST.st(animation, child, begin: 1, end: 0);
    //     },
    //   );

    default:
      return null;
  }
}
