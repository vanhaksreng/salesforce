import 'package:flutter/material.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';
import 'package:salesforce/core/utils/helpers.dart';

class TextWidget extends StatelessWidget {
  const TextWidget({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.fontWeight,
    this.color = textColor,
    this.decoration,
    this.decorationColor,
    this.height,
    this.maxLines,
    this.textAlign,
    this.overflow,
    this.softWrap,
    this.wordSpacing,
    this.fontStyle = FontStyle.normal,
  });

  final String text;
  final double fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final double? height;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final bool? softWrap;
  final FontStyle? fontStyle;
  final double? wordSpacing;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: _buildTextSpans(text)),
      maxLines: maxLines,
      textAlign: textAlign ?? TextAlign.start,
      overflow: overflow ?? TextOverflow.clip,
      softWrap: softWrap ?? true,
    );
  }

  List<TextSpan> _buildTextSpans(String text) {
    final List<TextSpan> spans = [];
    final textClr = color ?? textColor;

    text.splitMapJoin(
      Helpers.khmerRegex,
      onMatch: (match) {
        spans.add(
          TextSpan(
            text: greeting(match[0] ?? ""),
            style: TextStyle(
              fontFamily: 'Siemreap',
              fontSize: scaleFontSize(fontSize),
              fontWeight: fontWeight,
              color: textClr,
              decoration: decoration,
              decorationColor: decorationColor,
              height: height,
              letterSpacing: wordSpacing,
              wordSpacing: wordSpacing,
            ),
          ),
        );
        return match[0]!;
      },
      onNonMatch: (nonMatch) {
        spans.add(
          TextSpan(
            text: greeting(nonMatch),
            style: TextStyle(
              fontStyle: fontStyle,
              fontSize: scaleFontSize(fontSize),
              fontWeight: fontWeight,
              color: textClr,
              decoration: decoration,
              decorationColor: decorationColor,
              height: height,
              letterSpacing: wordSpacing,
              wordSpacing: wordSpacing,
            ),
          ),
        );

        return nonMatch;
      },
    );

    return spans;
  }
}
