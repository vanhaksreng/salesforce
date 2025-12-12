import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/more/presentation/pages/components/sale_history_detail_box.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/receipt_preview_screen.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/sale_order_history_detail_cubit.dart';
import 'package:salesforce/localization/trans.dart';
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
    with MessageMixin {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting(_getTitle()),
        actions: [
          BlocBuilder<SaleOrderHistoryDetailCubit, SaleOrderHistoryDetailState>(
            bloc: _cubit,
            builder: (tx, state) {
              final detail = state.record;
              final company = state.comPanyInfo;
              return BtnIconCircleWidget(
                onPressed: () {
                  Navigator.push(
                    context,
                    // MaterialPageRoute(
                    //   builder: (context) => ReceiptPreview58mmScreen(
                    //     companyInfo: company,
                    //     detail: detail,
                    //   ),
                    // ),
                    MaterialPageRoute(
                      builder: (context) => ReceiptPreviewScreen(
                        companyInfo: company,
                        detail: detail,
                      ),
                    ),
                  );
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
              if (state.isLoading) return const LoadingPageWidget();
              final record = state.record;
              return ListView(
                padding: const EdgeInsets.all(appSpace),
                children: [
                  SaleHistoryDetailBox(
                    header: record?.header,
                    lines: record?.lines ?? [],
                  ),
                ],
              );
            },
          ),
    );
  }
}
