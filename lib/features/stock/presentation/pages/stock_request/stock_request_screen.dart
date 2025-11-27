import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/stock/domain/entities/stock_args.dart';
import 'package:salesforce/features/stock/presentation/pages/stock_component/stock_box_request.dart';
import 'package:salesforce/features/stock/presentation/pages/stock_request/stock_request_cubit.dart';
import 'package:salesforce/features/stock/presentation/pages/stock_request/stock_request_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class StockRequestScreen extends StatefulWidget {
  const StockRequestScreen({super.key, required this.stockReqArg});
  final StockRequestArg stockReqArg;
  static const String routeName = "stockRequestPreviewScreen";

  @override
  State<StockRequestScreen> createState() => _StockRequestScreenState();
}

class _StockRequestScreenState extends State<StockRequestScreen>
    with MessageMixin {
  final _cubit = StockRequestCubit();
  ActionState action = ActionState.init;

  @override
  void initState() {
    super.initState();
    _cubit.getItemWorkSheets(
      param: {
        'quantity': '>0',
        'status': 'IN {"$kStatusPending","$kStatusNew"}',
      },
    );
  }

  void _onSubmitHandler() async {
    Helpers.showDialogAction(
      context,
      subtitle: 'Would you like to submit now?',
      confirm: () {
        Navigator.of(context).pop();
        _onSubmitStockRequest();
      },
    );
  }

  void _onSubmitStockRequest() async {
    final l = LoadingOverlay.of(context);
    l.show();
    await _cubit.submitStockRequest();
    l.hide();
  }

  void _onCancelRequestHandler() async {
    Helpers.showDialogAction(
      context,
      confirm: _processCancelStockRequest,
      labelAction: greeting("Cancel Stock"),
      subtitle: 'Would you like to cancel your stock request?',
    );
  }

  void _processCancelStockRequest() async {
    Navigator.of(context).pop();
    final l = LoadingOverlay.of(context);
    l.show();
    await _cubit.cancelStockRequest();
    l.hide();

    if (mounted && _cubit.state.headerStatus == kStatusClose) {
      Navigator.of(context).pop();
    }
  }

  void _onReceiveRequestHandler() async {
    final l = LoadingOverlay.of(context);
    l.show();
    await _cubit.receiveStockRequest();
    l.hide();
    action = ActionState.updated;
    if (mounted && _cubit.state.headerStatus == kStatusPosted) {
      Navigator.of(context).pop(action);
    }
  }

  void _onChangeReceiveQty(double qty, ItemStockRequestWorkSheet record) async {
    await _cubit.onChangeReceiveQty(qty, record);
  }

  void _onDelete(ItemStockRequestWorkSheet record) async {
    Helpers.showDialogAction(
      context,
      confirm: () {
        Navigator.of(context).pop();
        _cubit.deleteWorksheetItems(record.itemNo);
      },
      labelAction: greeting("delete"),
      subtitle:
          'Would you like to delete?\n'
          "${record.description ?? ''}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting("stock_request"),
        onBack: () => Navigator.of(context).pop(action),
      ),
      body: BlocBuilder<StockRequestCubit, StockRequestState>(
        bloc: _cubit,
        builder: (BuildContext context, StockRequestState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          return buildBody(state);
        },
      ),
      persistentFooterButtons: [
        BlocBuilder<StockRequestCubit, StockRequestState>(
          bloc: _cubit,
          builder: (context, state) {
            final records = state.itemWorkSheet;
            if (records.isEmpty) {
              return const SizedBox.shrink();
            }

            final docNo = records.first.documentNo ?? "";
            final hasReceiveQty = records.any(
              (e) => e.quantityShipped - e.quantityReceived > 0,
            );

            return switchBtn(state.headerStatus, docNo, hasReceiveQty);
          },
        ),
      ],
    );
  }

  Widget buildBody(StockRequestState state) {
    final records = state.itemWorkSheet;

    if (records.isEmpty) {
      return const EmptyScreen();
    }

    final docNo = records.first.documentNo ?? "";

    return Column(
      children: [
        if (docNo != "")
          BoxWidget(
            rounding: 6.scale,
            margin: EdgeInsets.symmetric(
              vertical: 6.scale,
              horizontal: scaleFontSize(appSpace8),
            ),
            padding: EdgeInsets.all(scaleFontSize(appSpace8)),
            width: double.infinity,
            child: Column(
              spacing: 6.scale,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(text: greeting("document_no")),
                    TextWidget(text: docNo, color: primary),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(text: greeting("Document Status")),
                    TextWidget(text: state.headerStatus, color: primary),
                  ],
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.all(scaleFontSize(appSpace)),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];

              return StockBoxRequest(
                key: ValueKey(index),
                record: record,
                onDelete: () => _onDelete(record),
                onChangedQty: (value) => _onChangeReceiveQty(value, record),
                readonly: docNo.isNotEmpty,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget switchBtn(String status, String docNo, [bool hasReceiveQty = false]) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: scaleFontSize(appSpace),
          vertical: scaleFontSize(6),
        ),
        child: Row(
          spacing: scaleFontSize(8),
          children: [
            Expanded(
              child: BtnWidget(
                gradient: linearGradient,
                title: switchAction(status).name,
                bgColor: switchAction(status).color,
                onPressed: switchAction(status).action,
              ),
            ),
            if (hasReceiveQty)
              Expanded(
                child: BtnWidget(
                  title: 'Receive Stock',
                  bgColor: primary,
                  onPressed: _onReceiveRequestHandler,
                ),
              ),
          ],
        ),
      ),
    );
  }

  ActionConfig switchAction(String status) {
    switch (status) {
      case "New":
        return ActionConfig(
          color: primary,
          name: greeting("submit"),
          action: _onSubmitHandler,
        );
      case "Open":
        return ActionConfig(
          color: error,
          name: greeting("cancel_request"),
          action: _onCancelRequestHandler,
        );
      case "Posted":
        return ActionConfig(
          color: success,
          name: greeting("recive_stock"),
          action: _onReceiveRequestHandler,
        );
      default:
        return ActionConfig(
          color: error,
          name: greeting("cancel_request"),
          action: _onCancelRequestHandler,
        );
    }
  }
}
