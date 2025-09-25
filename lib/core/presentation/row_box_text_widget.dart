import 'package:flutter/material.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/theme/app_colors.dart';

class RowBoxTextWidget extends StatelessWidget {
  const RowBoxTextWidget({
    super.key,
    required this.lable1,
    required this.value1,
    this.label2 = "",
    this.value2 = "",
    this.lable1Color = textColor50,
    this.value1Color = textColor,
    this.lable2Color = textColor50,
    this.value2Color = textColor,
    this.fontSizeLable = 12,
    this.fontSizeValue = 14,
    this.label1FontWeight = FontWeight.normal,
    this.value1FontWeight = FontWeight.bold,
    this.label2FontWeight = FontWeight.normal,
    this.value2FontWeight = FontWeight.bold,
    this.crossAxisAlignment1 = CrossAxisAlignment.start,
    this.crossAxisAlignment2 = CrossAxisAlignment.end,
  });

  final String lable1;
  final String value1;
  final String label2;
  final String value2;
  final FontWeight label1FontWeight;
  final FontWeight label2FontWeight;
  final FontWeight value1FontWeight;
  final FontWeight value2FontWeight;
  final Color lable1Color;
  final Color value1Color;
  final Color lable2Color;
  final Color value2Color;
  final double fontSizeLable;
  final double fontSizeValue;
  final CrossAxisAlignment crossAxisAlignment1;
  final CrossAxisAlignment crossAxisAlignment2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: Column(
              spacing: 8.scale,
              crossAxisAlignment: crossAxisAlignment1,
              children: [
                TextWidget(
                  text: lable1,
                  fontWeight: label1FontWeight,
                  color: lable1Color,
                  fontSize: fontSizeLable,
                ),
                TextWidget(
                  fontWeight: value1FontWeight,
                  text: value1,
                  fontSize: fontSizeValue,
                  color: value1Color,
                ),
              ],
            ),
          ),
          if (label2.isNotEmpty && value2.isNotEmpty)
            Expanded(
              child: Column(
                spacing: 8.scale,
                crossAxisAlignment: crossAxisAlignment2,
                children: [
                  TextWidget(
                    text: label2,
                    color: lable2Color,
                    fontWeight: label2FontWeight,
                    fontSize: fontSizeLable,
                  ),
                  TextWidget(
                    fontWeight: value2FontWeight,
                    text: value2,
                    color: value2Color,
                    fontSize: fontSizeValue,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
