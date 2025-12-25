import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/utils/no_emoji_text_formater.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/theme/app_colors.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({
    super.key,
    this.onSubmitted,
    this.suffixIcon,
    this.hintText = "Search here.",
    this.showPrefixIcon = true,
    this.borderColor,
    this.bgColor = Colors.transparent,
    this.svgIconColor = white,
    this.border,
    this.textColor = white,
    this.hintextColor = grey,
    this.onChanged,
    this.horizontal = 15,
    this.vertical = 15,
  });

  final Function(String)? onSubmitted;
  final String hintText;
  final Widget? suffixIcon;
  final bool showPrefixIcon;
  final Color? borderColor;
  final Color? textColor;
  final Color bgColor;
  final Color svgIconColor;
  final Color hintextColor;
  final InputBorder? border;
  final Function(String)? onChanged;
  final double horizontal;
  final double vertical;

  Widget? getPrefixIcon() {
    if (!showPrefixIcon) {
      return null;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace)),
      child: Icon(Icons.search, color: svgIconColor, size: 20.scale),
    );
  }

  InputBorder? _getBorder() {
    if (border != null) return border;

    return OutlineInputBorder(
      borderSide: BorderSide(color: borderColor ?? grey, width: 0.5),
      borderRadius: BorderRadius.circular(8.scale),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(horizontal), vertical: scaleFontSize(vertical)),
      child: SizedBox(
        height: 40.scale,
        child: TextField(
          inputFormatters: [NoEmojiTextInputFormatter()],
          style: TextStyle(color: textColor, fontSize: 14.scale),
          onSubmitted: (value) => onSubmitted?.call(value),
          onChanged: (value) => onChanged?.call(value),
          decoration: InputDecoration(
            filled: true,
            fillColor: bgColor,
            isCollapsed: false,
            isDense: true,
            prefixIcon: getPrefixIcon(),
            suffixIcon: suffixIcon,
            contentPadding: EdgeInsets.symmetric(vertical: scaleFontSize(8), horizontal: scaleFontSize(16)),
            constraints: BoxConstraints(maxHeight: scaleFontSize(48), minHeight: scaleFontSize(48)),
            focusedBorder: _getBorder(),
            border: _getBorder(),
            enabledBorder: _getBorder(),
            hintText: hintText,
            hintStyle: TextStyle(color: hintextColor, fontSize: 14.scale),
          ),
        ),
      ),
    );
  }
}
