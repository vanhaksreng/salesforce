import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/permission.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/image_box_cover_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_stock_submit_preview_competitor_item/check_stock_submit_preview_competitor_item_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/checkstock/check_stock_submit_preview_competitor_item/check_stock_submit_preview_competitor_item_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class CheckStockSubmitPreviewCompetitorItemScreen extends StatefulWidget {
  const CheckStockSubmitPreviewCompetitorItemScreen({super.key, required this.schedule});

  static const String routeName = "checkItemPreviewCompetitorScreen";
  final SalespersonSchedule schedule;

  @override
  State<CheckStockSubmitPreviewCompetitorItemScreen> createState() =>
      _CheckStockSubmitPreviewCompetitorItemScreenState();
}

class _CheckStockSubmitPreviewCompetitorItemScreenState extends State<CheckStockSubmitPreviewCompetitorItemScreen>
    with MessageMixin {
  final _cubit = CheckStockSubmitPreviewCompetitorItemCubit();

  Map<String, dynamic>? arguments;

  final boxPadding = EdgeInsets.symmetric(vertical: 12.scale, horizontal: 16.scale);

  @override
  void initState() {
    _cubit.initialize(schedule: widget.schedule);
    _cubit.getCompetitorItemLedgerEntries();
    super.initState();
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

      await _cubit.submitCheckStockCometitorItem().then((_) {
        showSuccessMessage("Submitted successfully");
      });

      l.hide();

      if (mounted) {
        Navigator.of(context).pop(ActionState.updated);
      }
    } on GeneralException catch (e) {
      l.hide();
      showErrorMessage(e.message);
    } catch (e) {
      l.hide();
      showErrorMessage(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: "Check stock previews"),
      body: BlocBuilder<CheckStockSubmitPreviewCompetitorItemCubit, CheckStockSubmitPreviewCompetitorItemState>(
        bloc: _cubit,
        builder: (BuildContext context, CheckStockSubmitPreviewCompetitorItemState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          return buildBody(state);
        },
      ),
      persistentFooterButtons: [
        BlocBuilder<CheckStockSubmitPreviewCompetitorItemCubit, CheckStockSubmitPreviewCompetitorItemState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.records.isEmpty) return const SizedBox.shrink();

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

  Widget buildBody(CheckStockSubmitPreviewCompetitorItemState state) {
    final records = state.records;
    final top = scaleFontSize(appSpace);

    if (records.isEmpty) {
      return const EmptyScreen();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace)),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];

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
                      imageUrl: "", //TODO
                      width: 70.scale,
                      height: 70.scale,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      spacing: 8.scale,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(text: record.itemDescription ?? "", fontWeight: FontWeight.bold, fontSize: 16.scale),
                        _stock(record),
                      ],
                    ),
                  ),
                ],
              ),
              _subBox(
                greeting('Volume Sales'),
                Helpers.formatNumberLink(record.volumeSalesQuantity, option: FormatType.quantity),
                " ${record.unitOfMeasureCode}",
              ),
              _subBox(greeting('Unit Price'), Helpers.formatNumberLink(record.unitPrice, option: FormatType.amount)),
              _subBox(greeting('Unit Cost'), Helpers.formatNumberLink(record.unitCost, option: FormatType.amount)),
            ],
          ),
        );
      },
    );
  }

  Widget _stock(CompetitorItemLedgerEntry record) {
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

  Widget _subBox(String text, String value, [String uomCode = ""]) {
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
          TextWidget(text: "$value$uomCode", fontWeight: FontWeight.bold),
        ],
      ),
    );
  }
}
