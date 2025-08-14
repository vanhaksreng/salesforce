import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/bottom_sheet_fn.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_text_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/stock/presentation/pages/stock_component/qty_input.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/item_prize_redemption/item_prize_redemption_card_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/item_prize_redemption/item_prize_redemption_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/item_prize_redemption/item_prize_redemption_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class ItemPrizeRedemptionScreen extends StatefulWidget {
  const ItemPrizeRedemptionScreen({super.key, required this.arg});
  static const String routeName = "itemPrizeRedemption";

  final DefaultProcessArgs arg;

  @override
  ItemPrizeRedemptionScreenState createState() => ItemPrizeRedemptionScreenState();
}

class ItemPrizeRedemptionScreenState extends State<ItemPrizeRedemptionScreen> with MessageMixin {
  final _cubit = ItemPrizeRedemptionCubit();

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  void _initLoad() async {
    await _cubit.initLoadData(widget.arg);
    await _cubit.getItemPrizeRedemptionHeader();
    await _cubit.getItemPrizeRedemptionEntries();
    _cubit.getItemPrizeRedemptionLine();
  }

  void _deleteHandler(ItemPrizeRedemptionHeader header) {
    Helpers.showDialogAction(
      context,
      subtitle: "Would you like to delete? ${header.description}",
      cancelText: "No, Keep it",
      confirmText: greeting("Yes, Delete"),
      confirm: () async {
        _cubit.deleteTakeInRedemption(header);
        Navigator.pop(context);
      },
    );
  }

  void buildTakeInQty(ItemPrizeRedemptionHeader header) {
    modalBottomSheet(
      context,
      child: QtyInput(
        key: const ValueKey("qty"),
        initialQty: "",
        onChanged: (value) {
          if (value <= 0) {
            return;
          }

          Navigator.of(context).pop();
          _cubit.processTakeInRedemption(header, value);
        },
        modalTitle: header.no,
        inputLabel: "Take In Quantity",
      ),
    );
  }

  void _submitHandler() async {
    if (_cubit.state.entries.isEmpty) {
      showWarningMessage("Nothing to submit");
      return;
    }

    Helpers.showDialogAction(
      context,
      subtitle: "Would you like to submit now?",
      confirm: () async {
        _cubit.processSubmitRedemption();
        Navigator.pop(context);
      },
    );
  }

  final boxPadding = const EdgeInsets.symmetric(horizontal: 15, vertical: 15);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting("item_prize_redemtion")),
      body: BlocBuilder<ItemPrizeRedemptionCubit, ItemPrizeRedemptionState>(
        bloc: _cubit,
        builder: (BuildContext context, ItemPrizeRedemptionState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          return buildBody(state);
        },
      ),
      persistentFooterButtons: [
        BlocBuilder<ItemPrizeRedemptionCubit, ItemPrizeRedemptionState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.entries.where((e) => e.status == kStatusOpen).isEmpty) {
              return const SizedBox.shrink();
            }
            return BtnWidget(
              horizontal: appSpace,
              onPressed: _submitHandler,
              gradient: linearGradient,
              title: "Submit",
            );
          },
        ),
      ],
    );
  }

  Widget buildBody(ItemPrizeRedemptionState state) {
    return ListView.builder(
      itemCount: state.headers.length,
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace)),
      itemBuilder: (context, index) {
        final header = state.headers[index];

        final lines = state.lines.where((l) => l.promotionNo == header.no).toList();
        final entries = state.entries.where((l) => l.promotionNo == header.no).toList();

        return BoxWidget(
          key: ValueKey(header.no),
          margin: EdgeInsets.symmetric(vertical: 8.scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(header, entries),
              Hr(width: double.infinity, vertical: scaleFontSize(6)),
              ItemPrizeRedemptionCardScreen(lines: lines, entries: entries),
              if (entries.isEmpty)
                BtnWidget(
                  onPressed: () => buildTakeInQty(header),
                  vertical: 8,
                  horizontal: appSpace,
                  textColor: mainColor,
                  bgColor: mainColor.withValues(alpha: .2),
                  title: greeting("Take In"),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ItemPrizeRedemptionHeader header, List<ItemPrizeRedemptionLineEntry> entries) {
    String status = kStatusOpen;
    if (entries.isNotEmpty) {
      status = entries.first.status ?? kStatusOpen;
    }

    return Container(
      key: ValueKey(header.no),
      padding: boxPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10.scale), topRight: Radius.circular(10.scale)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: scaleFontSize(8),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(text: header.no ?? "", fontSize: 16, fontWeight: FontWeight.bold),
              if (entries.isNotEmpty)
                if (status == kStatusOpen) ...[
                  BtnTextWidget(
                    onPressed: () => _deleteHandler(header),
                    bgColor: red.withValues(alpha: 0.1),
                    child: Row(
                      spacing: 4.scale,
                      children: const [
                        SvgWidget(assetName: kSvgDelete, width: 13, height: 13, colorSvg: red),
                        TextWidget(text: 'Delete', color: red, fontSize: 12),
                      ],
                    ),
                  ),
                ] else ...[
                  ChipWidget(
                    label: status.toUpperCase(),
                    bgColor: red.withValues(alpha: 0.1),
                    colorText: red,
                    vertical: 6.scale,
                  ),
                ],
            ],
          ),
          TextWidget(text: header.description ?? ""),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 4.scale,
                children: [
                  const Icon(Icons.calendar_month, color: grey, size: 16),
                  TextWidget(text: "${DateTimeExt.parse(header.fromDate).toDateNameString()} -"),
                  TextWidget(text: DateTimeExt.parse(header.toDate).toDateNameString()),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
