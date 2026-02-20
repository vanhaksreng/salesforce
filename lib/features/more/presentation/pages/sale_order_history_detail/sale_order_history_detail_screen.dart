import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/presentation/pages/components/sale_history_detail_box.dart';
import 'package:salesforce/features/more/presentation/pages/imin_device/imin_mixin.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/imin_device/receipt_imin.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/receipt_preview_screen.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/sale_order_history_detail_cubit.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class SaleOrderHistoryDetailScreen extends StatefulWidget {
  const SaleOrderHistoryDetailScreen({
    super.key,
    required this.documentNo,
    required this.typeDoc,
    required this.isSync,
  });

  final String documentNo;
  final String isSync;
  final String typeDoc;
  static const String routeName = "SaleOrderDetailHistoryScreen";

  @override
  State<SaleOrderHistoryDetailScreen> createState() =>
      _SaleOrderHistoryDetailScreenState();
}

class _SaleOrderHistoryDetailScreenState
    extends State<SaleOrderHistoryDetailScreen>
    with MessageMixin, IminPrinterMixin {
  final _cubit = SaleOrderHistoryDetailCubit();

  bool connected = false;
  String? connectedMac;
  String? connectingMac;
  String statusMessage = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await checkIminDevice();
    await _cubit.getSaleDetails(no: widget.documentNo, isSync: widget.isSync);
    await _cubit.getComapyInfo();
  }

  String _getTitle() {
    switch (widget.typeDoc) {
      case 'Invoice':
        return 'Sale Invoice Detail';
      case 'Order':
        return 'Sale Order Detail';
      default:
        return 'Sale Credit Memo Detail';
    }
  }

  void pushToPrintReceipt({
    CompanyInformation? company,
    SaleDetail? detail,
  }) async {
    if (await checkIminDevice()) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ReceiptImin(companyInfo: company, detail: detail);
          },
        ),
      );
    } else {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ReceiptPreviewScreen(companyInfo: company, detail: detail);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting(_getTitle()),
        actions: [
          BlocBuilder<SaleOrderHistoryDetailCubit, SaleOrderHistoryDetailState>(
            bloc: _cubit,
            builder: (tx, state) {
              return BtnIconCircleWidget(
                onPressed: () {
                  pushToPrintReceipt(company: state.comPanyInfo, detail: state.record);
                },
                icons: const Icon(Icons.print_rounded, color: white),
                rounded: appBtnRound,
              );
            },
          ),
          Helpers.gapW(appSpace),
        ],
      ),
      body:
          BlocBuilder<SaleOrderHistoryDetailCubit, SaleOrderHistoryDetailState>(
            bloc: _cubit,
            builder: (context, state) {
              if (state.isLoading) {
                return const LoadingPageWidget();
              }

              final record = state.record;
              final header = record?.header;
              final lines = record?.lines ?? [];

              final lineAmount = lines.fold<double>(
                0.0,
                (sum, line) => sum + Helpers.toDouble(line.amountIncludingVat),
              );

              return ListView(
                padding: const EdgeInsets.all(appSpace),
                children: [
                  SaleHistoryDetailBox(
                    header: header,
                    lines: lines,
                    lineAmount: Helpers.formatNumber(
                      lineAmount,
                      option: FormatType.amount,
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }
}
