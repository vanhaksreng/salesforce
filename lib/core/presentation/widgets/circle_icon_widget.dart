import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/theme/app_colors.dart';

class CircleIconWidget extends StatelessWidget {
  const CircleIconWidget({
    super.key,
    this.svgIcon = "",
    this.icon,
    this.onPress,
    this.bgColor = white,
    this.borderColor,
    this.sizeIcon = 24.0,
    this.widthSvg = 24.0,
    this.heightSvg = 24.0,
    this.paddingIcon = 4,
    this.colorIcon = textColor50,
  });
  final String svgIcon;
  final IconData? icon;
  final Color bgColor;
  final Color colorIcon;
  final Color? borderColor;
  final double? widthSvg;
  final double sizeIcon;
  final double heightSvg;
  final double paddingIcon;
  final VoidCallback? onPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: scaleFontSize(0)),
      child: IconButton(
        constraints: const BoxConstraints(),
        padding: EdgeInsets.all(scaleFontSize(paddingIcon)),
        style: ButtonStyle(
          side: WidgetStatePropertyAll(BorderSide(color: borderColor ?? bgColor, width: 0.5)),
          backgroundColor: WidgetStatePropertyAll(bgColor),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: svgIcon.isNotEmpty
            ? Transform.flip(
                flipX: true,
                child: SvgPicture.asset(
                  svgIcon,
                  colorFilter: ColorFilter.mode(colorIcon, BlendMode.srcIn),
                  width: widthSvg,
                  height: heightSvg,
                ),
              )
            : Icon(icon, size: sizeIcon, color: colorIcon),
        onPressed: onPress,
      ),
    );
  }
}
