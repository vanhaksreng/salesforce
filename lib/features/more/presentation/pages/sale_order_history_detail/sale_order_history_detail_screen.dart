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
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/components/sale_history_detail_box.dart';
import 'package:salesforce/features/more/presentation/pages/imin_device/imin_mixin.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/sale_order_history_detail_cubit.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
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

  void _openPrintReceiptSetting(SalesHeader header) async {
    final lines = _cubit.state.record?.lines ?? [];
    _cubit.openPrintReceiptSetting(context, header: header, lines: lines);
  }

  void _printReceipt(SalesHeader header) async {
    final lines = _cubit.state.record?.lines ?? [];

    try {
      await _cubit.printReceipt(context, header: header, lines: lines);
    } catch (e) {
      debugPrint(e.toString());
      showErrorMessage("An error occurred while printing the receipt.");
    }

    // if (await checkIminDevice()) {
    //   if (!mounted) return;
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) {
    //         return ReceiptImin(companyInfo: company, detail: detail);
    //       },
    //     ),
    //   );
    // } else {
    //   if (!mounted) return;
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) {
    //         return ReceiptPreviewScreen(companyInfo: company, detail: detail);
    //       },
    //     ),
    //   );
    // }
  }

  void _shareReceipt(SalesHeader header) async {
    await _cubit.shareSaleDocument(
      context,
      documentNo: header.no ?? "",
      documenType: header.documentType ?? "",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting(_getTitle()),
        heightBottom: 50,
        bottom:
            BlocBuilder<
              SaleOrderHistoryDetailCubit,
              SaleOrderHistoryDetailState
            >(
              bloc: _cubit,
              builder: (tx, state) {
                if (state.isLoading) {
                  return const SizedBox.shrink();
                }

                final header = state.record?.header;
                if (header == null) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: appSpace,
                    vertical: 8.scale,
                  ),
                  child: Row(
                    spacing: 6.scale,
                    children: [
                      BtnIconCircleWidget(
                        onPressed: () => _openPrintReceiptSetting(header),
                        icons: const Icon(Icons.tune, color: white),
                        rounded: appBtnRound,
                      ),
                      Spacer(),
                      BtnIconCircleWidget(
                        onPressed: () => _shareReceipt(header),
                        icons: const Icon(Icons.share, color: white),
                        rounded: appBtnRound,
                      ),

                      BtnIconCircleWidget(
                        onPressed: () => _printReceipt(header),
                        icons: const Icon(Icons.print_rounded, color: white),
                        rounded: appBtnRound,
                      ),
                    ],
                  ),
                );
              },
            ),
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
