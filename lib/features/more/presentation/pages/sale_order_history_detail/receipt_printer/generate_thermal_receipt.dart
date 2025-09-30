import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/receipt_helpers.dart';

// === MAIN PRINT FUNCTION ===
Future<List<int>> printRichKhmerTextFor80mm(
  List<StyledTextSegment> segments,
) async {
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm80, profile);
  List<int> bytes = [];

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

// === GENERATE IMAGE FUNCTION ===
Future<ByteData?> generateKhmerTextImageFor80mm(
  List<StyledTextSegment> segments,
  int width,
  int? height,
) async {
  segments = segments.where((segment) {
    if (segment.image != null) return true;
    return segment.text.trim().isNotEmpty && segment.text.trim() != "0";
  }).toList();
  final recorder = ui.PictureRecorder();
  final tempHeight = height ?? 2000;

  final canvas = ui.Canvas(
    recorder,
    ui.Rect.fromLTWH(0, 0, width.toDouble(), tempHeight.toDouble()),
  );

  // White background
  final paint = ui.Paint()..color = Colors.white;
  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), tempHeight.toDouble()),
    paint,
  );

  // double yOffset = XP323BConfig.topMargin.toDouble();
  double yOffset = XP323BConfig.topMargin > 0
      ? XP323BConfig.topMargin.toDouble()
      : 10.0;

  for (final segment in segments) {
    if (segment.image == null &&
        (segment.text.isEmpty || segment.text.trim().isEmpty)) {
      continue; // ← Add this check
    }
    if (segment.image != null) {
      // Draw image
      final uiCodec = await ui.instantiateImageCodec(segment.image!);
      final frame = await uiCodec.getNextFrame();
      final uiImage = frame.image;

      final targetWidth = (segment.imageWidth ?? uiImage.width).toDouble();
      final targetHeight = (segment.imageHeight ?? uiImage.height).toDouble();

      final srcRect = ui.Rect.fromLTWH(
        0,
        0,
        uiImage.width.toDouble(),
        uiImage.height.toDouble(),
      );
      final dstRect = ui.Rect.fromLTWH(
        (width - targetWidth) / 2, // center horizontally
        yOffset,
        targetWidth,
        targetHeight,
      );

      canvas.drawImageRect(uiImage, srcRect, dstRect, ui.Paint());
      yOffset += targetHeight + 10; // margin below image
    } else if (segment.isRow) {
      // Draw table row
      double rowHeight = _drawRow(
        canvas,
        segment.text,
        yOffset,
        width,
        fontSize: _getFontSizeFor80mm(segment.fontSize),
      );
      yOffset += rowHeight;
    } else if (segment.text.isNotEmpty) {
      // Draw normal text
      final span = TextSpan(
        text: segment.text,
        style: TextStyle(
          fontFamily: 'Siemreap',
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
        textAlign: segment.textAlign ?? TextAlign.left,
        maxLines: segment.maxline,
      );

      textPainter.layout(maxWidth: width.toDouble() - 40);

      // Calculate proper offset based on alignment
      Offset offset;
      switch (segment.textAlign) {
        case TextAlign.center:
          offset = Offset((width - textPainter.width) / 2, yOffset);
          break;
        case TextAlign.right:
          offset = Offset(width - textPainter.width - 20, yOffset);
          break;
        default:
          offset = Offset(20, yOffset); // left padding
      }

      textPainter.paint(canvas, offset);
      yOffset += textPainter.height + (segment.rowHeight ?? 0);
    }
  }

  final picture = recorder.endRecording();
  final calculatedHeight = height ?? (yOffset + 30).ceil();

  final uiImage = await picture.toImage(width, calculatedHeight);
  return await uiImage.toByteData(format: ui.ImageByteFormat.png);
}

// === TABLE ROW FUNCTION ===
double _drawRow(
  ui.Canvas canvas,
  String text,
  double y,
  int paperWidth, {
  double fontSize = 18,
}) {
  final lines = text.split('\n');
  double currentY = y;
  double lineHeight = fontSize + 16;

  for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
    if (lines[lineIndex].trim().isEmpty || lines[lineIndex].trim() == "0") {
      continue; // skip empty or "0" lines
    }
    final parts = lines[lineIndex].split('|');
    final colX = [10.0, 60.0, 280.0, 350.0, 420.0, 480.0];

    for (int i = 0; i < parts.length && i < colX.length; i++) {
      final cellText = parts[i].trim();
      if (cellText.isEmpty || cellText == "0") continue;
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
        maxLines: 1,
      );

      double maxWidth;
      if (i < colX.length - 1) {
        maxWidth = colX[i + 1] - colX[i] - 5;
      } else {
        maxWidth = paperWidth - colX[i] - 10;
      }

      tp.layout(maxWidth: maxWidth);
      tp.paint(canvas, Offset(colX[i], currentY));
    }

    currentY += lineHeight;
  }

  return currentY - y;
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
