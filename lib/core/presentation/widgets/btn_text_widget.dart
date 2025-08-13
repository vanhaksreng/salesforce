import 'package:flutter/material.dart';
import 'package:salesforce/theme/app_colors.dart';

class BtnTextWidget extends TextButton {
  BtnTextWidget({
    super.key,
    required VoidCallback? onPressed,
    required Widget child,
    Color bgColor = grey20,
    Color? borderColor,
    double horizontal = 12,
    double vertical = 8,
    double borderWith = 0,
    double? rounded,
  }) : super(
         onPressed: onPressed,
         style: ButtonStyle(
           backgroundColor: WidgetStateProperty.all(bgColor),
           shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular((rounded ?? 10)))),
           side: WidgetStatePropertyAll(BorderSide(width: borderWith, color: borderColor ?? bgColor)),
           padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical)),
           minimumSize: WidgetStateProperty.all(const Size(0, 0)),
         ),
         child: child,
       );
}
