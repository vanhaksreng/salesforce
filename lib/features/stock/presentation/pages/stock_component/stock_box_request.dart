import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/image_box_cover_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/circle_icon_widget.dart';
import 'package:salesforce/core/presentation/widgets/dot_line_widget.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/features/stock/presentation/pages/stock_component/qty_input.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class StockBoxRequest extends StatefulWidget {
  const StockBoxRequest({
    super.key,
    required this.record,
    required this.onChangedQty,
    this.onDelete,
    this.readonly = false,
  });

  final ItemStockRequestWorkSheet record;
  final void Function()? onDelete;
  final void Function(double value)? onChangedQty;
  final bool readonly;

  @override
  State<StockBoxRequest> createState() => _StockBoxRequestState();
}

class _StockBoxRequestState extends State<StockBoxRequest> {
  TextEditingController qtyController = TextEditingController();
  TextEditingController unitController = TextEditingController();

  @override
  void initState() {
    qtyController.text = "0";
    unitController.text = widget.record.unitOfMeasureCode ?? "";
    super.initState();
  }

  void _applyQty(double value) {
    Navigator.pop(context);
    widget.onChangedQty?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final receiveQty = widget.record.quantityShipped - widget.record.quantityReceived;

    return BoxWidget(
      key: widget.key,
      margin: EdgeInsets.symmetric(vertical: scaleFontSize(4)),
      padding: EdgeInsets.symmetric(vertical: scaleFontSize(appSpace8), horizontal: scaleFontSize(appSpace)),
      isBoxShadow: false,
      child: Row(
        spacing: scaleFontSize(appSpace8),
        children: [
          ImageBoxCoverWidget(
            key: ValueKey(widget.record.itemNo),
            image: ImageNetWorkWidget(
              key: ValueKey(widget.record.itemNo),
              imageUrl: '', //TODO: Add image URL from item
              height: 60.scale,
              fit: BoxFit.scaleDown,
              width: 60.scale,
            ),
          ),
          Expanded(
            child: Column(
              spacing: scaleFontSize(appSpace8 - 4),
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRowTitle(),
                if ((widget.record.description2 ?? "").isNotEmpty)
                  TextWidget(text: widget.record.description2 ?? '', color: textColor50),
                DotLine(color: grey.withValues(alpha: 0.5)),
                SizedBox(height: scaleFontSize(4)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: widget.record.quantity.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold, color: primary, fontSize: scaleFontSize(14)),
                          ),
                          TextSpan(
                            text: " / ${widget.record.unitOfMeasureCode}",
                            style: TextStyle(fontWeight: FontWeight.bold, color: primary, fontSize: scaleFontSize(14)),
                          ),
                        ],
                      ),
                    ),
                    if (receiveQty > 0)
                      InkWell(
                        onTap: () => _onOption(context),
                        child: Container(
                          width: 80.scale,
                          height: 30.scale,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(width: 0.5, color: grey),
                          ),
                          child: TextWidget(
                            text: Helpers.formatNumber(widget.record.quantityToReceive, option: FormatType.quantity),
                            color: primary,
                          ),
                        ),
                      ),
                    if (receiveQty <= 0 && widget.record.quantityReceived > 0)
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: textColor50, fontSize: scaleFontSize(14)),
                          children: <TextSpan>[
                            const TextSpan(text: "Received : "),
                            TextSpan(text: Helpers.formatNumber(widget.record.quantityReceived)),
                            const TextSpan(text: " / "),
                            TextSpan(text: Helpers.formatNumber(widget.record.quantity)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row _buildRowTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: TextWidget(text: widget.record.description ?? '', maxLines: 2)),
        // switchStatus(),
      ],
    );
  }

  Widget switchStatus() {
    if (!widget.readonly) {
      return CircleIconWidget(
        colorIcon: error,
        bgColor: error.withValues(alpha: 0.2),
        icon: Icons.delete,
        sizeIcon: 18,
        onPress: () {
          if (widget.onDelete != null) {
            widget.onDelete!();
          }
        },
      );
    }

    return ChipWidget(
      bgColor: secondary.withAlpha(30),
      colorText: widget.record.status == "Posted" ? success : primary,
      label: widget.record.status,
    );
  }

  _onOption(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: false,
      isDismissible: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(scaleFontSize(16)))),
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: QtyInput(
                key: const ValueKey("qty"),
                initialQty: Helpers.formatNumber(
                  widget.record.quantityShipped - widget.record.quantityReceived,
                  option: FormatType.quantity,
                ),
                onChanged: _applyQty,
                modalTitle: widget.record.description,
                inputLabel: "Quantity to receive",
              ),
            ),
          ),
        );
      },
    );
  }
}
