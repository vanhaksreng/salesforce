import 'package:flutter/material.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/theme/app_colors.dart';

class InfoBox extends StatelessWidget {
  final Color value1Color;
  final Color valueColor;
  final String label;
  final String value;
  final String value1;
  final FormatType type;

  const InfoBox({
    super.key,
    this.value1Color = textColor50,
    this.valueColor = primary,
    this.label = "",
    this.value = " 0",
    this.value1 = "0",
    this.type = FormatType.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BoxWidget(
        isBorder: false,
        padding: EdgeInsets.all(15.scale),
        borderColor: primary.withValues(alpha: .2),
        color: primary.withValues(alpha: 0.2),
        isBoxShadow: false,
        child: Column(
          spacing: 8.scale,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget(fontWeight: FontWeight.w600, color: textColor50, text: label.toUpperCase()),
            TextWidget(
              text: Helpers.formatNumber(value, option: type),
              fontSize: 20,
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
            TextWidget(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              text: Helpers.formatNumberLink(value1, option: FormatType.amount),
              color: value1Color,
            ),
          ],
        ),
      ),
    );
  }
}
