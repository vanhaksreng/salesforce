import 'package:flutter/material.dart';

import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/bottom_sheet_fn.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/stock/presentation/pages/stock_component/qty_input.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class ItemPosmAndMerchandingBox extends StatelessWidget {
  const ItemPosmAndMerchandingBox({super.key, required this.args});

  final ItemPosmAndMerchandise args;

  void _showQty(BuildContext context) {
    modalBottomSheet(
      context,
      child: QtyInput(
        key: const ValueKey("qty"),
        initialQty: Helpers.formatNumber(args.qtyStock, option: FormatType.quantity),
        onChanged: (double value) {
          Navigator.pop(context);
          args.onUpdateQty?.call(value);
        },
        modalTitle: args.description,
        inputLabel: "Request quantity",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BoxWidget(
      margin: EdgeInsets.only(bottom: scaleFontSize(8)),
      padding: EdgeInsets.all(scaleFontSize(16)),
      child: Column(spacing: scaleFontSize(appSpace), children: [headerPart(), footerPart(context)]),
    );
  }

  Widget footerPart(BuildContext context) {
    return BoxWidget(
      color: grey.withValues(alpha: 0.1),
      isBoxShadow: false,
      padding: EdgeInsets.all(scaleFontSize(8)),
      child: Row(
        spacing: scaleFontSize(appSpace),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: TextWidget(text: greeting("quantity").toUpperCase())),
          SizedBox(
            width: 100.scale,
            child: BtnWidget(
              radius: 8,
              borderColor: onChangeColor().withValues(alpha: .2),
              variant: BtnVariant.outline,
              size: BtnSize.small,
              textColor: onChangeColor(),
              onPressed: () => args.status == "Submitted" ? null : _showQty(context),
              title: Helpers.formatNumberLink(args.qtyStock, option: FormatType.quantity),
            ),
          ),
        ],
      ),
    );
  }

  Color onChangeColor() {
    if (args.status.isEmpty) {
      return mainColor50;
    }
    return success;
  }

  Widget headerPart() {
    return Row(
      spacing: scaleFontSize(appSpace),
      children: [
        Expanded(
          child: Column(
            spacing: 8.scale,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(text: args.description, color: mainColor, fontWeight: FontWeight.bold),
              if (args.description2.isNotEmpty)
                TextWidget(fontWeight: FontWeight.bold, fontSize: 16, text: args.description2),
            ],
          ),
        ),
        if (args.status.isNotEmpty)
          ChipWidget(label: args.status, colorText: onChangeColor(), bgColor: onChangeColor().withValues(alpha: .2)),
      ],
    );
  }
}
