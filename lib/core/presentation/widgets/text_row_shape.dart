import 'package:flutter/material.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class TextShapeRow extends StatelessWidget {
  final Color? valueColor;
  final String label;
  final String value;
  final double labelFontSize;
  final double valueFontSize;

  final Color labelColor;
  final FontWeight valueFontWeight;
  final FontWeight labelFontWeight;

  const TextShapeRow({
    super.key,
    this.valueColor,
    this.label = "",
    this.value = "",
    this.labelFontSize = 16,
    this.valueFontSize = 18,
    this.labelColor = textColor50,
    this.valueFontWeight = FontWeight.bold,
    this.labelFontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget(color: labelColor, fontWeight: labelFontWeight, text: label, fontSize: labelFontSize),
        TextWidget(text: value, fontSize: valueFontSize, color: valueColor, fontWeight: valueFontWeight),
      ],
    );
  }
}
