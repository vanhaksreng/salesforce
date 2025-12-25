import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class BadgeWidget extends StatelessWidget {
  const BadgeWidget({super.key, this.label, this.icon, this.iconSvg = "", this.colorIcon = white});
  final String? label;
  final IconData? icon;
  final String iconSvg;
  final Color colorIcon;

  @override
  Widget build(BuildContext context) {
    return Badge(
      label: TextWidget(text: label ?? "", color: white),
      backgroundColor: error,
      child: switchWidget(iconSvg),
    );
  }

  Widget switchWidget(String value) {
    if (value.isNotEmpty) {
      return svgWidget();
    }
    return Icon(icon, size: scaleFontSize(26), color: colorIcon);
  }

  Widget svgWidget() {
    return SvgPicture.asset(
      iconSvg,
      colorFilter: ColorFilter.mode(colorIcon, BlendMode.srcIn),
      width: 20.scale,
      height: 20.scale,
    );
  }
}
