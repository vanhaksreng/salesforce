import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/domain/entities/app_args.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/bottom_sheet_fn.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/stock/presentation/pages/build_uom_selected/build_uom_selected.dart';
import 'package:salesforce/features/stock/presentation/pages/stock_component/qty_input.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class StockBox extends StatefulWidget {
  const StockBox({
    super.key,
    this.isReadonly = false,
    required this.item,
    this.onChangedQty,
    this.onChangedUom,
    this.qty = "",
    this.uom = "",
  });

  final Item item;
  final String qty;
  final String uom;
  final bool isReadonly;
  final Function(double qty, String uomCode)? onChangedQty;
  final Function(double qty, String uomCode)? onChangedUom;

  @override
  State<StockBox> createState() => _StockBoxState();
}

class _StockBoxState extends State<StockBox> with MessageMixin {
  late final ValueNotifier<String> _uomCode;
  late String qty;

  @override
  void initState() {
    qty = widget.qty;
    _uomCode = ValueNotifier(widget.item.salesUomCode ?? "");
    super.initState();
  }

  void _applyQty(double value) {
    Navigator.pop(context);
    qty = Helpers.formatNumber(value, option: FormatType.quantity);
    widget.onChangedQty?.call(value, widget.uom);
  }

  void _onSelectedUom(String value) {
    if (Helpers.toDouble(qty) <= 0) {
      showWarningMessage("Request quantity is required. Please input quantity first.");
      return;
    }

    widget.onChangedUom?.call(Helpers.toDouble(qty), value);
    _uomCode.value = value;
  }

  @override
  Widget build(BuildContext context) {
    final inventory = Helpers.formatNumber(widget.item.inventory);

    return BoxWidget(
      key: widget.key,
      margin: EdgeInsets.symmetric(vertical: scaleFontSize(4)),
      padding: EdgeInsets.symmetric(vertical: scaleFontSize(appSpace8), horizontal: scaleFontSize(appSpace)),
      isBorder: true,
      borderColor: grey20,
      isBoxShadow: false,
      child: Row(
        spacing: scaleFontSize(appSpace8),
        children: [
          buildImageNetWorkWidget(),
          Expanded(
            child: Column(
              spacing: scaleFontSize(appSpace8 - 4),
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(text: widget.item.description ?? '', maxLines: 2, fontWeight: FontWeight.bold),
                if ((widget.item.description2 ?? "").isNotEmpty)
                  TextWidget(text: widget.item.description2 ?? '', color: textColor50, maxLines: 2),
                if (inventory.isEmpty)
                  ChipWidget(
                    label: "Out of stock",
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    bgColor: warning.withValues(alpha: 0.1),
                    colorText: orangeColor,
                  ),
                if (inventory.isNotEmpty)
                  TextWidget(
                    text: "$inventory / ${widget.item.stockUomCode}",
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: success,
                  ),
                const Hr(width: double.infinity, vertical: 6, color: grey20),
                buildFooter(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFooter(BuildContext context) {
    return Row(
      spacing: scaleFontSize(appSpace8),
      children: [
        InkWell(
          onTap: () => _onOption(context, OptionType.qty),
          child: Container(
            width: 100.scale,
            height: 30.scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.isReadonly ? grey.withValues(alpha: 0.4) : null,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(width: 0.5, color: grey),
            ),
            child: TextWidget(text: qty),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: _uomCode,
          builder: (context, uomCode, _) {
            return InkWell(
              onTap: () => _onOption(context, OptionType.uom),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.scale),
                height: 30.scale,
                width: 100.scale,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.isReadonly ? grey.withValues(alpha: 0.4) : null,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(width: 0.5, color: grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(text: uomCode.isEmpty ? "--" : uomCode),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Row buildRowTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: TextWidget(text: widget.item.description ?? '', maxLines: 2)),
        BoxWidget(
          rounding: 4,
          padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace8), vertical: scaleFontSize(4)),
          color: secondary.withValues(alpha: 0.3),
          child: TextWidget(
            text: "${widget.item.inventory} /${widget.item.stockUomCode}",
            fontSize: 12,
            color: primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  ImageNetWorkWidget buildImageNetWorkWidget() {
    return ImageNetWorkWidget(
      key: ValueKey(widget.item.no),
      imageUrl: widget.item.picture ?? '',
      height: 70.scale,
      fit: BoxFit.cover,
      width: 70.scale,
    );
  }

  void _onOption(BuildContext context, OptionType type) {
    if (widget.isReadonly) return;

    if (type == OptionType.uom && Helpers.toDouble(qty) <= 0) {
      showWarningMessage("Request quantity is required.");
      return;
    }

    modalBottomSheet(
      context,
      child: SafeArea(
        child: SingleChildScrollView(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: switchWidget(type),
          ),
        ),
      ),
    );
  }

  Widget switchWidget(OptionType type) {
    if (type == OptionType.qty) {
      return QtyInput(
        key: const ValueKey("qty"),
        initialQty: Helpers.formatNumber(qty, option: FormatType.quantity),
        onChanged: _applyQty,
        modalTitle: widget.item.description,
        inputLabel: "Request quantity",
      );
    }
    return BuildUomSelected(
      arg: BuildUomArg(
        inputLabel: widget.item.description,
        modalTitle: widget.item.description,
        itemNo: widget.item.no,
        uomCode: _uomCode.value,
        onChanged: _onSelectedUom,
      ),
      key: const ValueKey("uom"),
    );
  }
}
