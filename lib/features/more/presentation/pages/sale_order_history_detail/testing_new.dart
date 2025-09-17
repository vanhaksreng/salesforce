import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;

class StyledTextSegment {
  final String text;
  final KhmerTextStyle style;
  final KhmerFontSize fontSize;
  final Color? color;
  final int maxline;
  final bool isDescription;

  StyledTextSegment({
    required this.text,
    this.style = KhmerTextStyle.normal,
    this.fontSize = KhmerFontSize.normal,
    this.color,
    this.maxline = 2,
    this.isDescription = false,
  });
}

enum KhmerTextStyle { normal, bold, italic, boldItalic }

enum KhmerFontSize { small, normal, large, extraLarge }

class XP323BPrinter {
  final BluetoothDevice device;
  BluetoothCharacteristic? _writeCharacteristic;

  XP323BPrinter(this.device);

  Future<void> connect() async {
    await device.connect(autoConnect: false).catchError((_) {});
    final services = await device.discoverServices();
    for (var service in services) {
      for (var char in service.characteristics) {
        if (char.properties.write || char.properties.writeWithoutResponse) {
          _writeCharacteristic = char;
          return;
        }
      }
    }
    if (_writeCharacteristic == null) {
      throw Exception("No writable characteristic found.");
    }
  }

  Future<void> printRichKhmerText(List<StyledTextSegment> segments) async {
    if (_writeCharacteristic == null) return;

    final image = await _generateRichKhmerTextImage(segments, 576);
    final bwImage = _convertTo1Bit(image);
    final rasterBytes = _generateRasterBytes(bwImage);
    await _sendDataInChunks(rasterBytes);
  }

  Future<img.Image> _generateRichKhmerTextImage(
    List<StyledTextSegment> segments,
    int width,
  ) async {
    final recorder = ui.PictureRecorder();
    final tempHeight = 2000;
    final canvas = ui.Canvas(
      recorder,
      ui.Rect.fromLTWH(0, 0, width.toDouble(), tempHeight.toDouble()),
    );

    final paint = ui.Paint()..color = Colors.white;
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, width.toDouble(), tempHeight.toDouble()),
      paint,
    );

    double yOffset = 30;
    for (final segment in segments) {
      final span = TextSpan(
        text: segment.text,
        style: TextStyle(
          fontFamily: 'Siemreap',
          fontSize: _getFontSize(segment.fontSize),
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
      final columnWidth = segment.isDescription ? 150.0 : width.toDouble() - 40;
      textPainter.layout(maxWidth: columnWidth);
      textPainter.paint(canvas, Offset(20, yOffset));
      yOffset += textPainter.height;
    }

    final picture = recorder.endRecording();
    final uiImage = await picture.toImage(width, yOffset.ceil());
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    final uint8list = byteData!.buffer.asUint8List();
    final img.Image? finalImage = img.decodePng(uint8list);
    return finalImage!;
  }

  img.Image _convertTo1Bit(img.Image input) {
    final gray = img.grayscale(input);
    final bw = img.Image(width: gray.width, height: gray.height);

    final black = img.ColorRgb8(0, 0, 0);
    final white = img.ColorRgb8(255, 255, 255);

    for (int y = 0; y < gray.height; y++) {
      for (int x = 0; x < gray.width; x++) {
        final pixel = gray.getPixel(x, y);
        final luma = img.getLuminance(pixel);
        bw.setPixel(x, y, luma < 128 ? black : white);
      }
    }

    return bw;
  }

  List<int> _generateRasterBytes(img.Image bwImage) {
    List<int> bytes = [];
    int width = bwImage.width;
    int height = bwImage.height;

    bytes.addAll([
      0x1D,
      0x76,
      0x30,
      0x00,
      (width ~/ 8) & 0xFF,
      ((width ~/ 8) >> 8) & 0xFF,
      height & 0xFF,
      (height >> 8) & 0xFF,
    ]);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x += 8) {
        int byte = 0;
        for (int bit = 0; bit < 8; bit++) {
          if (x + bit < width) {
            final pixel = bwImage.getPixel(x + bit, y);
            final r = pixel.r; // Access red channel directly
            if (r == 0) byte |= (1 << (7 - bit));
          }
        }
        bytes.add(byte);
      }
    }

    return bytes;
  }

  Future<void> _sendDataInChunks(List<int> data, {int chunkSize = 100}) async {
    if (_writeCharacteristic == null) return;
    for (var i = 0; i < data.length; i += chunkSize) {
      final end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
      final chunk = data.sublist(i, end);
      await _writeCharacteristic!.write(chunk, withoutResponse: false);
      await Future.delayed(Duration(milliseconds: 30));
    }
  }

  double _getFontSize(KhmerFontSize fontSize) {
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
}
