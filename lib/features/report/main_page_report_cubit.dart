import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/mixins/permission_mixin.dart';
import 'package:salesforce/features/report/domain/entities/menu_report.dart';
import 'package:salesforce/features/report/main_page_report_state.dart';
import 'package:salesforce/features/report/presentation/pages/customer_balance_report/customer_balance_report_screen.dart';
import 'package:salesforce/features/report/presentation/pages/daily_sale_summary_report/daily_sale_summary_report_screen.dart';
import 'package:salesforce/features/report/presentation/pages/item_inventory_report/item_inventory_report_screen.dart';
import 'package:salesforce/features/report/presentation/pages/so_outstanding_report/so_outstanding_report_screen.dart';
import 'package:salesforce/features/report/presentation/pages/stock_request_report/stock_request_report_screen.dart';
import 'package:salesforce/localization/trans.dart';

class MainPageReportCubit extends Cubit<MainPageReportState> with PermissionMixin {
  MainPageReportCubit() : super(const MainPageReportState(isLoading: true));

  Future<void> initLoadData() async {
    await initializeReports();
  }

  Future<void> initializeReports() async {
    try {
      final reports = [
        // MenuReport(
        //   icon: Icons.star,
        //   title: greeting("Call Compliance"),
        //   subTitle: greeting("text something"),
        //   routeName: "", //TODO
        //   show: await hasPermission("call_compliance_report"),
        // ),
        // MenuReport(
        //   icon: Icons.star,
        //   title: greeting("Call Positioning Duration"),
        //   subTitle: greeting("text something"),
        //   routeName: "", //TODO
        //   show: await hasPermission("call_positioning_duration_report"),
        // ),
        // MenuReport(
        //   icon: Icons.star,
        //   title: greeting("Sales Performance By SKU"),
        //   subTitle: greeting("text something"),
        //   routeName: "", //TODO
        //   show: await hasPermission("sales_performace_by_sku_report"),
        // ),
        // MenuReport(
        //   icon: Icons.star,
        //   title: greeting("Call Effectiveness"),
        //   subTitle: greeting("text something"),
        //   routeName: "", //TODO
        //   show: await hasPermission("call_effectiveness_report"),
        // ),
        // MenuReport(
        //   icon: Icons.star,
        //   title: greeting("Call Effectiveness By Item"),
        //   subTitle: greeting("text something"),
        //   routeName: "", //TODO
        //   show: await hasPermission("call_effectiveness_by_item_report"),
        // ),
        MenuReport(
          icon: Icons.star,
          title: greeting("so_outstanding"),
          subTitle: greeting("track_order_ship_pending"),
          routeName: SoOutstandingReportScreen.routeName,
          show: await hasPermission("so_outstanding_report"),
        ),
        MenuReport(
          icon: Icons.assessment,
          title: greeting("daily_sales_summary"),
          subTitle: greeting("overview_summary_of_sale_performance"),
          routeName: DailySaleSummaryReportScreen.routeName,
          show: await hasPermission("daily_sales_summary_report"),
        ),
        MenuReport(
          icon: Icons.account_balance,
          title: greeting("customer_balance"),
          subTitle: greeting("outstadind_amount_the_customer_owes"),
          routeName: CustomerBalanceReportScreen.routeName,
          show: await hasPermission("customer_balance_report"),
        ),
        MenuReport(
          icon: Icons.inventory_2,
          title: greeting("item_inventory"),
          subTitle: greeting("effficiently_manage_stock_levels_and_availability"),
          routeName: ItemInventoryReportScreen.routeName,
          show: await hasPermission("item_inventory"),
        ),
        // MenuReport(
        //   icon: Icons.request_quote,
        //   title: greeting("Cash Transaction"),
        //   subTitle: greeting("text something"),
        //   routeName: "", //TODO
        //   show: await hasPermission("cash_transaction_report"),
        // ),
        MenuReport(
          icon: Icons.request_quote,
          title: greeting("stock_request"),
          subTitle: greeting("manage_and_track_stock_replenishment_request"),
          routeName: StockRequestReportScreen.routeName,
          show: await hasPermission("stock_request_report"),
        ),
        // MenuReport(
        //   icon: Icons.redeem,
        //   title: greeting("Item Redemption by Salesperson"),
        //   subTitle: greeting("manage_redemptions_made_by_saleperson"),
        //   routeName: ItemRedemptionBySalespersonReportScreen.routeName,
        //   show: await hasPermission("item_redemption_report"),
        // ),
      ];

      emit(state.copyWith(reports: reports, isLoading: false));
    } catch (e) {
      // Handle error
    }
  }
}
