import 'package:flutter/material.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class ChipWidget extends StatelessWidget {
  const ChipWidget({
    super.key,
    this.child,
    this.label = "",
    this.vertical = 8,
    this.horizontal = 8,
    this.radius = 16,
    this.bgColor = primary,
    this.borderColor,
    this.colorText = white,
    this.fontSize = 12,
    this.isCircle = false,
    this.ishadowColor = false,
    this.fontWeight = FontWeight.bold,
    this.onDeleted,
  });

  final Widget? child;
  final String label;
  final double vertical;
  final double horizontal;
  final Color bgColor;
  final Color? borderColor;
  final Color colorText;
  final double radius;
  final double fontSize;
  final bool isCircle;
  final bool ishadowColor;
  final FontWeight? fontWeight;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    return Chip(
      elevation: 8,
      onDeleted: onDeleted,
      deleteIconColor: colorText,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.symmetric(vertical: scaleFontSize(vertical), horizontal: scaleFontSize(horizontal)),
      backgroundColor: bgColor,
      shadowColor: ishadowColor ? bgColor.withValues(alpha: .3) : null,
      color: WidgetStatePropertyAll(bgColor),
      side: BorderSide(color: borderColor ?? bgColor, width: 0),
      visualDensity: VisualDensity.compact,
      shape: borderShape(isCircle),
      avatar: null,
      // labelPadding: EdgeInsets.only(bottom: 16.scale),
      label: showLabel(),
    );
  }

  Widget showLabel() {
    if (label.isNotEmpty && child != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextWidget(text: label, fontWeight: fontWeight, fontSize: fontSize, color: colorText),
          if (child != null) ...[child!],
        ],
      );
    } else if (label.isNotEmpty && child == null) {
      return TextWidget(text: label, fontWeight: fontWeight, fontSize: fontSize, color: colorText);
    }

    return child!;
  }

  OutlinedBorder borderShape(bool isCircle) {
    if (isCircle) {
      return const CircleBorder();
    }

    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
  }
}
