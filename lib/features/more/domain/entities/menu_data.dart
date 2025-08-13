import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/permission.dart';
import 'package:salesforce/core/mixins/permission_mixin.dart';
import 'package:salesforce/features/more/domain/entities/more_model.dart';
import 'package:salesforce/features/more/presentation/pages/customers/customers_screen.dart';
import 'package:salesforce/features/more/presentation/pages/downloads/download_screen.dart';
import 'package:salesforce/features/more/presentation/pages/promotion/promotion_screen.dart';
import 'package:salesforce/features/more/presentation/pages/redemptions/redemptions_screen.dart';
import 'package:salesforce/features/more/presentation/pages/sale_credit_memo_history/sale_credit_memo_history_screen.dart';
import 'package:salesforce/features/more/presentation/pages/sale_invoice_history/sale_invoice_history_screen.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history/sale_order_history_screen.dart';
import 'package:salesforce/features/more/presentation/pages/upload/upload_screen.dart';
import 'package:salesforce/localization/trans.dart';

class MenuData with PermissionMixin {
  Future<List<MoreModel>> getListMenus() async {
    return [
      MoreModel(
        title: greeting("sale_orders"),
        subTitle: greeting("manage_and_track all sale orders"),
        icon: Icons.upload_file,
        routeName: SaleOrderHistoryScreen.routeName,
        isShow: await hasPermission(kUseSaleOrder),
        arg: Args(titelArg: greeting("sale_orders"), parentTitle: greeting("more")),
      ),
      MoreModel(
        title: greeting("sale_invoices"),
        subTitle: greeting("generate_and_manage_invoice"),
        icon: Icons.featured_play_list_outlined,
        routeName: SaleInvoiceHistoryScreen.routeName,
        isShow: await hasPermission(kUseSaleInvoice),
        arg: Args(titelArg: greeting("sale_invoices"), parentTitle: greeting("more")),
      ),
      MoreModel(
        title: greeting("sale_credit_memo"),
        subTitle: greeting("process_returns_and_refunds"),
        icon: Icons.view_list_outlined,
        routeName: SaleCreditMemoHistoryScreen.routeName,
        isShow: await hasPermission(kUseSaleCredit),
        arg: Args(titelArg: greeting("sale_credit_memo"), parentTitle: greeting("more")),
      ),
      MoreModel(
        title: greeting("customers"),
        subTitle: greeting("create_customers_add_addres"),
        icon: Icons.person_outline,
        routeName: CustomersScreen.routeName,
        arg: Args(titelArg: greeting("customers"), parentTitle: greeting("more")),
      ),
      MoreModel(
        title: greeting("promotions"),
        subTitle: greeting("manage_promotion"),
        icon: Icons.discount_outlined,
        routeName: PromotionScreen.routeName,
        arg: Args(titelArg: greeting("promotions"), parentTitle: greeting("more")),
      ),
      MoreModel(
        title: greeting("Redemptions"),
        subTitle: greeting("Getting a product or prize by redeeming points or codes"),
        icon: Icons.redeem,
        routeName: RedemptionsScreen.routeName,
        isShow: await hasPermission(kUseItemPriceRedeption),
        arg: Args(titelArg: greeting("redemptions"), parentTitle: greeting("more")),
      ),
      MoreModel(
        title: greeting("download"),
        subTitle: greeting("download_data_from_setup"),
        icon: Icons.cloud_download_outlined,
        routeName: DownloadScreen.routeName,
        arg: Args(titelArg: greeting("download"), parentTitle: greeting("more")),
      ),
      MoreModel(
        title: greeting("upload"),
        subTitle: greeting("upload_data_to_server"),
        icon: Icons.cloud_upload_outlined,
        routeName: UploadScreen.routeName,
        arg: Args(titelArg: greeting("upload"), parentTitle: greeting("more")),
      ),
    ];
  }
}
