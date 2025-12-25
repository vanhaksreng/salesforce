import 'package:flutter/material.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class TextBtnWidget extends StatelessWidget {
  const TextBtnWidget({
    super.key,
    required this.onTap,
    this.colorBtn = error,
    required this.titleBtn,
    this.fontSize = 14,
    this.textDecoration = TextDecoration.none,
    this.textAlign = TextAlign.center,
    this.fontWeight = FontWeight.normal,
    this.text,
  });

  final VoidCallback onTap;
  final Color colorBtn;
  final String titleBtn;
  final double fontSize;
  final FontWeight fontWeight;
  final TextDecoration textDecoration;
  final TextAlign textAlign;
  final Widget? text;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(50, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: Alignment.centerLeft,
      ),
      child: text != null
          ? text!
          : TextWidget(
              fontWeight: fontWeight,
              text: greeting(titleBtn),
              color: colorBtn,
              decoration: textDecoration,
              fontSize: fontSize,
            ),
    );
  }
}
