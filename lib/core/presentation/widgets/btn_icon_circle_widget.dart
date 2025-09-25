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
    this.widthIcon = 24,
    this.heightIcon = 24,
    this.padiingIcon = 8,
  });

  final void Function()? onPressed;
  final Color bgColor;
  final Widget icons;
  final bool isShowBadge;
  final double? rounded;
  final double widthIcon;
  final double heightIcon;
  final double padiingIcon;
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
          padding: WidgetStatePropertyAll(
            EdgeInsets.all(scaleFontSize(padiingIcon)),
          ),
          backgroundColor: WidgetStatePropertyAll(bgColor),
          shape: rounded == null
              ? null
              : WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      scaleFontSize(rounded!),
                    ),
                  ),
                ),
        ),
        iconSize: 20.scale,
        icon: Transform.flip(
          flipX: flipX,
          child: SizedBox(
            width: scaleFontSize(widthIcon),
            height: scaleFontSize(heightIcon),
            child: icons,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
