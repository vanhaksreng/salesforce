import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/theme/app_colors.dart';

class SvgWidget extends StatelessWidget {
  const SvgWidget({
    super.key,
    this.assetName = "",
    this.width = 24,
    this.height = 24,
    this.colorSvg = primary,
    this.padding,
  });
  final String assetName;
  final double width;
  final double height;
  final Color colorSvg;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(0),
      child: SvgPicture.asset(
        matchTextDirection: true,
        assetName,
        excludeFromSemantics: true,
        allowDrawingOutsideViewBox: true,
        alignment: Alignment.center,
        fit: BoxFit.cover,
        width: scaleFontSize(width),
        height: scaleFontSize(height),
        colorFilter: ColorFilter.mode(colorSvg, BlendMode.srcIn),
      ),
    );
  }
}
