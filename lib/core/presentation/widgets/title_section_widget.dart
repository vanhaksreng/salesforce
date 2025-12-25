import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/icon_svg_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class TitleSectionWidget extends StatelessWidget {
  final String label;
  final String rightLabel;
  final Widget? child;
  final double pb;
  final double pt;
  final double line;
  final GestureTapCallback? onTap;
  final Color color;
  final double fontSize;
  final double width;
  final bool? isRightChildIcon;
  final String? iconRightChildIcon;
  final double horizontalPt;

  const TitleSectionWidget({
    super.key,
    required this.label,
    this.rightLabel = "",
    this.child,
    this.pb = 0,
    this.pt = 0,
    this.onTap,
    this.color = grey,
    this.fontSize = 18,
    this.width = 0.65,
    this.line = 0,
    this.isRightChildIcon = false,
    this.iconRightChildIcon,
    this.horizontalPt = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: super.key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            BoxWidget(gradient: linearGradient, height: 18.scale, width: 4.scale, child: const SizedBox()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: scaleFontSize(horizontalPt)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(text: label, fontWeight: FontWeight.w700, fontSize: fontSize),
                  InkWell(
                    onTap: onTap,
                    child: isRightChildIcon == false
                        ? TextWidget(
                            text: rightLabel,
                            decoration: TextDecoration.underline,
                            color: color,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            decorationColor: color,
                          )
                        : rightChild(),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (pt > 0) SizedBox(height: pt),
        if (child != null) child!,
        if (line > 0) SizedBox(height: pb),
        if (line > 0)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: scaleFontSize(6)),
            child: Hr(width: double.infinity, height: line, color: grey),
          ),
        if (pb > 0) SizedBox(height: pb),
      ],
    );
  }

  Widget rightChild() {
    return BoxWidget(
      isBoxShadow: false,
      child: Padding(
        padding: EdgeInsets.all(5.scale),
        child: IconSvgWidget(
          assetName: iconRightChildIcon!,
          size: 18.scale,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          onPressed: () {},
        ),
      ),
    );
  }
}
