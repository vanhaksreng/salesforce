import 'package:flutter/material.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/theme/app_colors.dart';

class BtnIconCircleWidget extends StatelessWidget {
  const BtnIconCircleWidget({
    super.key,
    required this.onPressed,
    this.bgColor = boxColor,
    required this.icons,
    this.rounded,
    this.isShowBadge = false,
    this.flipX = true,
  });

  final void Function()? onPressed;
  final Color bgColor;
  final Widget icons;
  final bool isShowBadge;
  final double? rounded;
  final bool flipX;

  @override
  Widget build(BuildContext context) {
    return Badge(
      smallSize: 10.scale,
      backgroundColor: error,
      isLabelVisible: isShowBadge,
      child: IconButton(
        constraints: BoxConstraints(maxHeight: 48.scale, maxWidth: 48.scale),
        alignment: Alignment.center,
        style: ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.all(scaleFontSize(8))),
          backgroundColor: WidgetStatePropertyAll(bgColor),
          shape: rounded == null
              ? null
              : WidgetStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(scaleFontSize(rounded!))),
                ),
        ),
        iconSize: 20.scale,
        icon: Transform.flip(
          flipX: flipX,
          child: SizedBox(width: 24.scale, height: 24.scale, child: icons),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
