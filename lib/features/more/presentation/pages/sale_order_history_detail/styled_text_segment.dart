import 'dart:ui';

import 'package:salesforce/core/enums/enums.dart';

class StyledTextSegment {
  final String text;
  final KhmerTextStyle style;
  final KhmerFontSize fontSize;
  final Color? color;

  StyledTextSegment({
    required this.text,
    this.style = KhmerTextStyle.normal,
    this.fontSize = KhmerFontSize.normal,
    this.color,
  });
}
