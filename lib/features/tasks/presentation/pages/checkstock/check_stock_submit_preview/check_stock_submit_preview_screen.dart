import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/permission.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/image_box_cover_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_stock_submit_preview/check_stock_submit_preview_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_stock_submit_preview/check_stock_submit_preview_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class CheckStockSubmitPreviewScreen extends StatefulWidget {
  const CheckStockSubmitPreviewScreen({super.key, required this.arg});

  static const String routeName = "checkItemPreviewScreen";
  final CheckStockArgs arg;

  @override
  State<CheckStockSubmitPreviewScreen> createState() => _CheckStockSubmitPreviewScreenState();
}

class _CheckStockSubmitPreviewScreenState extends State<CheckStockSubmitPreviewScreen> with MessageMixin {
  final _cubit = CheckStockSubmitPreviewCubit();

  Map<String, dynamic>? arguments;

  final boxPadding = EdgeInsets.symmetric(vertical: 12.scale, horizontal: 16.scale);

  @override
  void initState() {
    super.initState();
    _cubit.initialize(schedule: widget.arg.schedule);
    _initLoad();
  }

  void _initLoad() async {
    await _cubit.getCustomerItemLedgerEntries();
    await _cubit.getItems();
  }

  void _onSubmitHandler() {
    Helpers.showDialogAction(
      context,
      labelAction: greeting("submit"),
      subtitle: "Do you want to submit now?",
      confirmText: "Yes",
      cancelText: "No",
      confirm: () {
        Navigator.pop(context);
        _onProcessSubmit();
      },
    );
  }

  void _onProcessSubmit() async {
    final l = LoadingOverlay.of(context);
    l.show();
    try {
      if (!await _cubit.hasPermission(kAPartialCheckStock)) {
        throw GeneralException("You do not have permission to submit stock check.");
      }

      await _cubit.submitCheckStock();
      l.hide();

      if (mounted) {
        Navigator.pop(context);
      }
    } on GeneralException catch (e) {
      l.hide();
      showErrorMessage(e.message);
    } catch (e) {
      l.hide();
      showErrorMessage(e.toString());
    }
  }

  void _ondeleteItem(Item? record) {
    if (record == null) {
      return;
    }
    Helpers.showDialogAction(
      context,
      labelAction: greeting("Comfirm"),
      subtitle: greeting("Are you sure to delete?"),
      confirm: () {
        Navigator.of(context).pop();
        _cubit.deleteItem(record, widget.arg.schedule);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: "Check stock previews"),
      body: BlocBuilder<CheckStockSubmitPreviewCubit, CheckStockSubmitPreviewState>(
        bloc: _cubit,
        builder: (BuildContext context, CheckStockSubmitPreviewState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          return buildBody(state);
        },
      ),
      persistentFooterButtons: [
        BlocBuilder<CheckStockSubmitPreviewCubit, CheckStockSubmitPreviewState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.records.isEmpty) {
              return const SizedBox.shrink();
            }

            return SafeArea(
              child: BtnWidget(
                gradient: linearGradient,
                horizontal: scaleFontSize(appSpace8),
                title: greeting("Submit"),
                onPressed: () => _onSubmitHandler(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildBody(CheckStockSubmitPreviewState state) {
    final records = state.records;

    final top = scaleFontSize(appSpace);

    if (records.isEmpty) {
      return const EmptyScreen();
    }

    final items = state.items;

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace)),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];

        Item? item;

        final itemIndex = items.indexWhere((e) => e.no == record.itemNo);
        if (itemIndex != -1) {
          item = items[itemIndex];
        }

        return BoxWidget(
          margin: EdgeInsets.only(top: top),
          padding: EdgeInsets.all(top),
          key: ValueKey(record.entryNo),
          child: Column(
            spacing: 8.scale,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  ImageBoxCoverWidget(
                    key: ValueKey(record.entryNo),
                    image: ImageNetWorkWidget(
                      key: ValueKey(record.entryNo),
                      imageUrl: item?.avatar128 ?? "",
                      width: 70.scale,
                      height: 70.scale,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      spacing: 8.scale,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextWidget(
                                text: record.itemDescription ?? "",
                                fontWeight: FontWeight.bold,
                                fontSize: 16.scale,
                              ),
                            ),
                            BtnIconCircleWidget(
                              flipX: false,
                              bgColor: error.withValues(alpha: 0.2),
                              onPressed: () => _ondeleteItem(item),
                              icons: Icon(Icons.delete_forever_rounded, size: 24.scale, color: error),
                            ),
                          ],
                        ),
                        _stock(record),
                      ],
                    ),
                  ),
                ],
              ),
              _subBox(
                greeting('qty_bought_form_other'),
                Helpers.formatNumberLink(record.quantityBuyFromOther, option: FormatType.quantity),
                record.unitOfMeasureCode ?? "",
              ),
              _subBox(
                greeting('suggest_order_qty'),
                Helpers.formatNumberLink(record.plannedQuantity, option: FormatType.quantity),
                record.unitOfMeasureCode ?? "",
              ),
              _subBox(
                greeting('qty_return'),
                Helpers.formatNumberLink(record.plannedQuantityReturn, option: FormatType.quantity),
                record.unitOfMeasureCode ?? "",
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stock(CustomerItemLedgerEntry record) {
    if (Helpers.formatNumber(record.quantity).isEmpty) {
      return TextWidget(text: "Out of stock", fontWeight: FontWeight.bold, color: warning, fontSize: 14.scale);
    }

    return TextWidget(
      text:
          "${Helpers.formatNumberLink(record.quantity, option: FormatType.quantity)} ${record.unitOfMeasureCode} Available",
      fontWeight: FontWeight.bold,
      color: primary,
      fontSize: 14.scale,
    );
  }

  Widget _subBox(String text, String value, String uomCode) {
    if (value.isEmpty || value == '-') {
      return const SizedBox.shrink();
    }

    return BoxWidget(
      padding: boxPadding,
      isBoxShadow: false,
      color: grey.withAlpha(40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget(text: text),
          TextWidget(text: "$value $uomCode", fontWeight: FontWeight.bold),
        ],
      ),
    );
  }
}
