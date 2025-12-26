import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/presentation/widgets/list_tile_wiget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/title_section_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/auth/presentation/pages/login/login_screen.dart';
import 'package:salesforce/features/more/domain/entities/more_model.dart';
import 'package:salesforce/features/more/more_main_page_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/sale_credit_memo_history/sale_credit_memo_history_screen.dart';
import 'package:salesforce/features/more/presentation/pages/sale_invoice_history/sale_invoice_history_screen.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history/sale_order_history_screen.dart';
import 'package:salesforce/features/more/presentation/pages/upload/upload_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/upload/upload_screen.dart';
import 'package:salesforce/theme/app_colors.dart';

class BuildMore extends StatefulWidget {
  const BuildMore({
    super.key,
    required this.listActionMore,
    required this.lable,
  });

  final List<MoreModel> listActionMore;
  final String lable;

  @override
  State<BuildMore> createState() => _BuildMoreState();
}

class _BuildMoreState extends State<BuildMore> {
  final upload = UploadCubit();

  @override
  void initState() {
    upload.loadSalesData();
    super.initState();
  }

  int checkSaleUploadByRoute(String routeName) {
    final data = upload.state.salesHeaders;

    String? documentType;

    switch (routeName) {
      case SaleOrderHistoryScreen.routeName:
        documentType = kSaleOrder;
        break;
      case SaleInvoiceHistoryScreen.routeName:
        documentType = kSaleInvoice;
        break;
      case SaleCreditMemoHistoryScreen.routeName:
        documentType = kSaleCreditMemo;
        break;
    }

    if (documentType == null) return 0;

    return data
        .where((e) => e.isSync == kStatusNo && e.documentType == documentType)
        .length;
  }

  void _navigatorToScreen(BuildContext context, int index) {
    String routeName = widget.listActionMore[index].routeName;

    if (routeName == "logout") {
      _confirmLogout(context);
      return;
    }

    Navigator.pushNamed(
      context,
      routeName,
      arguments: widget.listActionMore[index].arg,
    ).then((state) async {
      if (state == null) return;
      if (Helpers.shouldReload(state)) {
        await upload.loadSalesData();
        checkSaleUploadByRoute(routeName);
      }
    });
  }

  void _confirmLogout(BuildContext context) {
    Helpers.showDialogAction(
      context,
      confirmText: "Yes, Log Out",
      cancelText: "No, Stay Logged In",
      confirm: () => _processLogout(context), // This is fine as it's a callback
    );
  }

  Future<bool> checkUploadData(
    BuildContext context,
    LoadingOverlay overlay,
  ) async {
    await upload.loadInitialData(DateTime.now());
    final state = upload.state;

    bool nothingToUpload =
        state.salesHeaders.isEmpty &&
        state.cashReceiptJournals.isEmpty &&
        state.customerItemLedgerEntries.isEmpty &&
        state.competitorItemLedgerEntries.isEmpty &&
        state.merchandiseSchedules.isEmpty &&
        state.redemptions.isEmpty;

    if (!nothingToUpload) {
      overlay.hide();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Helpers.showDialogAction(
          context,
          labelAction: "Upload Data",
          confirmText: "Go to upload",
          cancelText: "No, Cancel",
          confirm: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, UploadScreen.routeName);
          },
          subtitle:
              "Looks like you still have data to upload. Please upload it before logging out.",
        );
      });
      return false;
    }

    return true;
  }

  Future<void> _processLogout(BuildContext context) async {
    final overlay = LoadingOverlay.of(context);
    Navigator.pop(context);

    overlay.show();

    final canContinue = await checkUploadData(context, overlay);

    if (canContinue) {
      if (!context.mounted) return;

      final cubit = context.read<MoreMainPageCubit>();
      final result = await cubit.logout();

      if (!result || !context.mounted) {
        overlay.hide();
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TitleSectionWidget(
      label: widget.lable,
      pt: scaleFontSize(appSpace8),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: widget.listActionMore.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (widget.listActionMore[index].isShow == false) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 2.scale),
            child: ListTitleWidget(
              countNumber: checkSaleUploadByRoute(
                widget.listActionMore[index].routeName,
              ),
              onTap: () => _navigatorToScreen(context, index),
              label: widget.listActionMore[index].title,
              leading: Icon(
                widget.listActionMore[index].icon,
                size: 24.scale,
                color: mainColor,
              ),
              subTitle: widget.listActionMore[index].subTitle,
            ),
          );
        },
      ),
    );
  }
}
