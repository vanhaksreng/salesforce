import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class ListTitleWidget extends StatelessWidget {
  const ListTitleWidget({
    super.key,
    this.label = "",
    this.leading,
    this.subTitle = "",
    this.subTitleFontSize = 13,
    this.onTap,
    this.trailing,
    this.subtitleWidget,
    this.isSelected = false,
    this.type = ListTileType.trailingArrow,
    this.isRed = false,
    this.textColor,
    this.minTileHeight = 8,
    this.fontSizeLabel = 14,
    this.borderRadius = appSpace8,
    this.countNumber = 0,
    this.borderColor = grey,
    this.fontWeight = FontWeight.bold,
  });

  final String label;
  final String subTitle;
  final double subTitleFontSize;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final Widget? subtitleWidget;
  final Color? textColor;
  final Color borderColor;
  final bool isRed;
  final bool isSelected;
  final ListTileType type;
  final double borderRadius;
  final double minTileHeight;
  final double fontSizeLabel;
  final int countNumber;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(scaleFontSize(borderRadius)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(scaleFontSize(borderRadius)),
        splashColor: mainColor50.withValues(alpha: .2),
        highlightColor: mainColor50.withValues(alpha: .1),
        child: ListTile(
          shape: shapeRounding(),
          dense: false,
          enabled: true,
          tileColor: white,
          hoverColor: mainColor50.withValues(alpha: .1),
          splashColor: mainColor50.withValues(alpha: .2),
          focusColor: mainColor50.withValues(alpha: .1),
          selectedTileColor: mainColor50.withValues(alpha: .1),
          leading: leading != null
              ? BoxWidget(
                  rounding: 6,
                  color: mainColor50.withValues(alpha: .1),
                  isBoxShadow: false,
                  width: 36.scale,
                  height: 36.scale,
                  child: leading!,
                )
              : null,
          minVerticalPadding: scaleFontSize(minTileHeight),
          selected: isSelected,
          contentPadding: EdgeInsets.only(right: 16.scale, left: 16.scale),
          trailing: trailing ?? trailingWidget(),
          onTap: onTap,
          title: titleText(),
          subtitle: subtitleWidget ?? subTitleText(),
        ),
      ),
    );
  }

  Widget subTitleText() {
    if (subTitle.isNotEmpty && subtitleWidget == null) {
      return Padding(
        padding: EdgeInsets.only(top: 4.scale),
        child: TextWidget(text: subTitle, color: textColor50, fontSize: subTitleFontSize),
      );
    }
    return Padding(
      padding: EdgeInsets.only(top: 4.scale),
      child: subtitleWidget,
    );
  }

  RoundedRectangleBorder shapeRounding() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(scaleFontSize(borderRadius)),
      side: const BorderSide(color: grey20),
    );
  }

  TextWidget titleText() {
    return TextWidget(
      text: label,
      fontSize: fontSizeLabel,
      color: isRed ? error : Colors.black87,
      fontWeight: fontWeight,
    );
  }

  Widget trailingWidget() {
    if (type == ListTileType.trailingSelect) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isSelected
            ? Icon(Icons.check_circle_rounded, key: const ValueKey(true), size: scaleFontSize(24), color: primary)
            : const SizedBox.shrink(key: ValueKey(false)),
      );
    }
    return IntrinsicWidth(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Visibility(
            visible: countNumber > 0,
            child: Icon(Icons.circle, color: red, size: scaleFontSize(10)),
          ),
          Icon(Icons.arrow_forward_ios, color: grey, size: scaleFontSize(16)),
        ],
      ),
    );
  }
}
