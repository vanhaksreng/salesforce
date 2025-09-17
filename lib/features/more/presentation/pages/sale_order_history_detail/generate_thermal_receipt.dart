import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

// === MAIN PRINT FUNCTION ===
Future<List<int>> printRichKhmerTextFor80mm(
  List<StyledTextSegment> segments,
) async {
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm80, profile);

  List<int> bytes = [];

  // XP-P323B supports up to 576 pixels width for 80mm paper
  const int paperWidthPixels = 576;

  final image = await generateRichKhmerTextAsImgImage(
    segments,
    paperWidthPixels,
    null,
  );

  if (image != null) {
    bytes += generator.image(image);
  }

  bytes += generator.feed(1);
  return bytes;
}

// === RENDER TO IMAGE ===
Future<ByteData?> generateKhmerTextImageFor80mm(
  List<StyledTextSegment> segments,
  int width,
  int? height,
) async {
  final recorder = ui.PictureRecorder();
  final tempHeight = height ?? 2000;

  final canvas = ui.Canvas(
    recorder,
    ui.Rect.fromLTWH(0, 0, width.toDouble(), tempHeight.toDouble()),
  );

  // Background white
  final paint = ui.Paint()..color = Colors.white;
  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), tempHeight.toDouble()),
    paint,
  );

  double yOffset = XP323BConfig.topMargin.toDouble();

  for (final segment in segments) {
    if (segment.isRow) {
      // === SPECIAL CASE: DRAW TABLE ROW WITH FIXED COLUMNS ===
      _drawRow(
        canvas,
        segment.text,
        yOffset,
        width,
        fontSize: _getFontSizeFor80mm(segment.fontSize),
      );
      yOffset += segment.rowHeight ?? 32; // step down
    } else {
      // === NORMAL SINGLE LINE TEXT ===
      final span = TextSpan(
        text: segment.text,
        style: TextStyle(
          fontFamily: 'Siemreap', // or load another Khmer font
          fontSize: _getFontSizeFor80mm(segment.fontSize),
          fontWeight: _getFontWeight(segment.style),
          fontStyle: _getFontStyle(segment.style),
          color: segment.color ?? Colors.black,
          height: 1.3,
        ),
      );

      final textPainter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        maxLines: segment.maxline,
      );

      textPainter.layout(maxWidth: width.toDouble() - 40);
      textPainter.paint(canvas, Offset(20, yOffset));
      yOffset += textPainter.height;
    }
  }

  final picture = recorder.endRecording();
  final calculatedHeight = height ?? (yOffset + 30).ceil();

  final uiImage = await picture.toImage(width, calculatedHeight);
  return await uiImage.toByteData(format: ui.ImageByteFormat.png);
}

// === TABLE DRAWING FUNCTION ===
void _drawRow(
  ui.Canvas canvas,
  String text,
  double y,
  int paperWidth, {
  double fontSize = 18,
}) {
  // Split row by | (pipe) delimiter
  // Example row text: "1|HANUMAN BEER|2|2.00|—|4.00"
  final parts = text.split('|');

  // Define X positions for columns (tweak as needed for 80mm = 576px)
  final colX = [10.0, 60.0, 300.0, 370.0, 440.0, 510.0];

  for (int i = 0; i < parts.length; i++) {
    final span = TextSpan(
      text: parts[i].trim(),
      style: TextStyle(
        fontFamily: 'Siemreap',
        fontSize: fontSize,
        color: Colors.black,
      ),
    );

    final tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      textAlign: i == 0 || i == 1 ? TextAlign.left : TextAlign.right,
    );

    tp.layout(
      maxWidth: (i < colX.length - 1) ? (colX[i + 1] - colX[i] - 5) : 80,
    ); // keep columns separate

    tp.paint(canvas, Offset(colX[i], y));
  }
}

// === WRAPPER TO IMAGE ===
Future<img.Image?> generateRichKhmerTextAsImgImage(
  List<StyledTextSegment> segments,
  int width,
  int? height,
) async {
  final byteData = await generateKhmerTextImageFor80mm(segments, width, height);
  if (byteData == null) return null;
  final uint8List = byteData.buffer.asUint8List();
  return img.decodePng(uint8List);
}

// === FONT SETTINGS ===
double _getFontSizeFor80mm(KhmerFontSize fontSize) {
  switch (fontSize) {
    case KhmerFontSize.small:
      return 14.0;
    case KhmerFontSize.normal:
      return 18.0;
    case KhmerFontSize.large:
      return 24.0;
    case KhmerFontSize.extraLarge:
      return 30.0;
  }
}

FontWeight _getFontWeight(KhmerTextStyle style) {
  switch (style) {
    case KhmerTextStyle.bold:
    case KhmerTextStyle.boldItalic:
      return FontWeight.bold;
    default:
      return FontWeight.normal;
  }
}

FontStyle _getFontStyle(KhmerTextStyle style) {
  switch (style) {
    case KhmerTextStyle.italic:
    case KhmerTextStyle.boldItalic:
      return FontStyle.italic;
    default:
      return FontStyle.normal;
  }
}

// === ENUMS ===
enum KhmerTextStyle { normal, bold, italic, boldItalic }

enum KhmerFontSize { small, normal, large, extraLarge }

// === STYLED SEGMENT ===
class StyledTextSegment {
  final String text;
  final KhmerTextStyle style;
  final KhmerFontSize fontSize;
  final Color? color;
  final int maxline;
  final bool isRow; // NEW FLAG: true = table row
  final double? rowHeight;

  StyledTextSegment({
    required this.text,
    this.style = KhmerTextStyle.normal,
    this.fontSize = KhmerFontSize.normal,
    this.color,
    this.maxline = 2,
    this.isRow = false,
    this.rowHeight,
  });
}

// === XP-P323B CONFIG ===
class XP323BConfig {
  static const PaperSize paperSize = PaperSize.mm80;
  static const int paperWidthPixels = 576;
  static const int leftMargin = 20;
  static const int topMargin = 30;
}
