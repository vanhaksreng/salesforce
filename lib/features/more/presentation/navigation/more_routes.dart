import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/app/route_slide_transaction.dart';
import 'package:salesforce/features/more/domain/entities/add_customer_arg.dart';
import 'package:salesforce/features/more/domain/entities/cart_preview_arg.dart';
import 'package:salesforce/features/more/domain/entities/item_sale_arg.dart';
import 'package:salesforce/features/more/domain/entities/more_model.dart';
import 'package:salesforce/features/more/presentation/pages/about/about_screen.dart';
import 'package:salesforce/features/more/presentation/pages/add_customer/add_customer_screen.dart';
import 'package:salesforce/features/more/presentation/pages/administration/administration_screen.dart';
import 'package:salesforce/features/more/presentation/pages/bussiness_unit/bussiness_unit_screen.dart';
import 'package:salesforce/features/more/presentation/pages/cart_preview_item/cart_preview_item_screen.dart';
import 'package:salesforce/features/more/presentation/pages/customer_address/customer_address_screen.dart';
import 'package:salesforce/features/more/presentation/pages/customer_address_form/customer_address_form_screen.dart';
import 'package:salesforce/features/more/presentation/pages/customer_detail/customer_detail_screen.dart';
import 'package:salesforce/features/more/presentation/pages/customer_group/customer_group_screen.dart';
import 'package:salesforce/features/more/presentation/pages/customer_map/customer_map_full_screen_screen.dart';
import 'package:salesforce/features/more/presentation/pages/customers/customers_screen.dart';
import 'package:salesforce/features/more/presentation/pages/downloads/download_screen.dart';
import 'package:salesforce/features/more/presentation/pages/items/items_screen.dart';
import 'package:salesforce/features/more/presentation/pages/profile_form/profile_form_screen.dart';
import 'package:salesforce/features/more/presentation/pages/promotion/promotion_screen.dart';
import 'package:salesforce/features/more/presentation/pages/promotion_detail/promotion_detail_screen.dart';
import 'package:salesforce/features/more/presentation/pages/redemptions/redemptions_screen.dart';
import 'package:salesforce/features/more/presentation/pages/reset_password/reset_password_screen.dart';
import 'package:salesforce/features/more/presentation/pages/sale_credit_memo_history/sale_credit_memo_history_screen.dart';
import 'package:salesforce/features/more/presentation/pages/sale_credit_memo_history_detail/sale_credit_memo_history_detail_screen.dart';
import 'package:salesforce/features/more/presentation/pages/sale_form_item/sale_form_item_screen.dart';
import 'package:salesforce/features/more/presentation/pages/sale_invoice_history/sale_invoice_history_screen.dart';
import 'package:salesforce/features/more/presentation/pages/sale_invoice_history_detail/sale_invoice_history_detail_screen.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history/sale_order_history_screen.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/sale_order_history_detail_screen.dart';
import 'package:salesforce/features/more/presentation/pages/upload/upload_screen.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

Route<dynamic>? moreOnGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case SaleOrderHistoryScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const SaleOrderHistoryScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case SaleInvoiceHistoryScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const SaleInvoiceHistoryScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case SaleCreditMemoHistoryScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const SaleCreditMemoHistoryScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case CustomersScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const CustomersScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case PromotionScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const PromotionScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case CustomerAddressScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return CustomerAddressScreen(
            customer: settings.arguments as Customer,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case DownloadScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          final args = settings.arguments as Args;
          return DownloadScreen(arg: args);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case AboutScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const AboutScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case SaleCreditMemoHistoryDetailScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          final args = settings.arguments as Map<String, dynamic>;
          final String documentNo = args["documentNo"] as String;
          return SaleCreditMemoHistoryDetailScreen(documentNo: documentNo);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case SaleInvoiceHistoryDetailScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          final args = settings.arguments as Map<String, dynamic>;
          final documentNo = args["documentNo"] as String;
          return SaleInvoiceHistoryDetailScreen(documentNo: documentNo);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case SaleOrderHistoryDetailScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          final args = settings.arguments as Map<String, dynamic>;
          final documentNo = args["documentNo"] as String;
          final docType = args["docType"] as String;
          final isSync = args["isSync"] as String;
          return SaleOrderHistoryDetailScreen(
            documentNo: documentNo,
            typeDoc: docType,
            isSync: isSync,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case CustomerDetailScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return CustomerDetailScreen(customer: settings.arguments as Customer);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case CustomerGroupScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const CustomerGroupScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case BussinessUnitScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const BussinessUnitScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case CustomerMapFullScreenScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          final latlng = settings.arguments as LatLng;
          return CustomerMapFullScreenScreen(latLng: latlng);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    // case CustomerAddressScreen.routeName:
    //   return PageRouteBuilder(
    //     pageBuilder: (context, animation, secondaryAnimation) {
    //       return CustomerAddressScreen();
    //     },
    //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //       return RouteST.st(animation, child, begin: 1, end: 0);
    //     },
    //   ); TODO
    case UploadScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const UploadScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    // case InvoicePrinterScreen.routeName:
    //   return PageRouteBuilder(
    //     pageBuilder: (context, animation, secondaryAnimation) {
    //       return const InvoicePrinterScreen();
    //     },
    //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //       return RouteST.st(animation, child, begin: 1, end: 0);
    //     },
    //   );

    case PromotionDetailScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return PromotionDetailScreen(
            arg: settings.arguments as ItemPromotionHeader,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case CustomerAddressFormScreen.routeName:
      final args = settings.arguments as Map<String, dynamic>;
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return CustomerAddressFormScreen(
            address: args['address'] ?? null as CustomerAddress?,
            customerNo: args['customer'] as String,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case RedemptionsScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const RedemptionsScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case ProfileFormScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const ProfileFormScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case ResetPasswordScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const ResetPasswordScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case AddCustomerScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return AddCustomerScreen(
            addCustomerArg: settings.arguments as AddCustomerArg,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case ItemsScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ItemsScreen(args: settings.arguments as ItemSaleArg);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case SaleFormItemScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return SaleFormItemScreen(args: settings.arguments as ItemSaleArg);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    case CartPreviewItemScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return CartPreviewItemScreen(
            args: settings.arguments as CartPreviewArg,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );

    case AdministrationScreen.routeName:
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return AdministrationScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RouteST.st(animation, child, begin: 1, end: 0);
        },
      );
    default:
      return null;
  }
}