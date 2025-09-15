import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:image/image.dart' as img;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

Future<List<int>> printRichKhmerTextFor80mm(
  List<StyledTextSegment> segments,
) async {
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm80, profile); // 80mm paper size

  List<int> bytes = [];

  // Width for 80mm paper (approximately 576 pixels)
  // XP-P323B supports up to 576 dots width for 80mm paper
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

// Updated image generation for 80mm paper
// Future<ByteData?> generateKhmerTextImageFor80mm(
//   List<StyledTextSegment> segments,
//   int width,
//   int? height,
// ) async {
//   final recorder = ui.PictureRecorder();

//   List<TextSpan> textSpans = segments.map((segment) {
//     return TextSpan(
//       text: segment.text,
//       style: TextStyle(
//         fontFamily: 'Siemreap',

//         fontSize: _getFontSizeFor80mm(
//           segment.fontSize,
//         ), // Larger fonts for 80mm
//         fontWeight: _getFontWeight(segment.style),
//         fontStyle: _getFontStyle(segment.style),
//         color: segment.color ?? Colors.black,
//         height: 1.3,
//       ),
//     );
//   }).toList();

//   final textPainter = TextPainter(
//     text: TextSpan(children: textSpans),
//     textDirection: TextDirection.ltr,
//     textAlign: TextAlign.left,
//   );

//   // More margin for 80mm paper
//   textPainter.layout(maxWidth: width.toDouble() - 40);

//   final calculatedHeight = height ?? (textPainter.height + 60).ceil();

//   final canvas = ui.Canvas(
//     recorder,
//     ui.Rect.fromLTWH(0, 0, width.toDouble(), calculatedHeight.toDouble()),
//   );

//   // Fill background
//   final paint = ui.Paint()..color = Colors.white;
//   canvas.drawRect(
//     ui.Rect.fromLTWH(0, 0, width.toDouble(), calculatedHeight.toDouble()),
//     paint,
//   );

//   // Paint text with larger margins for 80mm
//   textPainter.paint(canvas, const ui.Offset(20, 30));

//   final picture = recorder.endRecording();
//   final uiImage = await picture.toImage(width, calculatedHeight);
//   final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);

//   return byteData;
// }

Future<ByteData?> generateKhmerTextImageFor80mm(
  List<StyledTextSegment> segments,
  int width,
  int? height, {
  bool isDescription = false,
}) async {
  final recorder = ui.PictureRecorder();

  // Temporary large height, we'll crop later
  final tempHeight = height ?? 2000;

  final canvas = ui.Canvas(
    recorder,
    ui.Rect.fromLTWH(0, 0, width.toDouble(), tempHeight.toDouble()),
  );

  // Fill background
  final paint = ui.Paint()..color = Colors.white;
  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), tempHeight.toDouble()),
    paint,
  );

  double yOffset = XP323BConfig.topMargin.toDouble(); // start below top margin

  for (final segment in segments) {
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
      textAlign: TextAlign.left,
      maxLines: segment.maxline,
    );

    final columnWidth = segment.isDescription ? 150.0 : width.toDouble() - 40;

    textPainter.layout(maxWidth: columnWidth);

    textPainter.paint(canvas, Offset(20, yOffset));
    yOffset += textPainter.height;
  }

  final picture = recorder.endRecording();
  final calculatedHeight = height ?? (yOffset + 30).ceil();

  final uiImage = await picture.toImage(width, calculatedHeight);
  final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);

  return byteData;
}

Future<img.Image?> generateRichKhmerTextAsImgImage(
  List<StyledTextSegment> segments,
  int width,
  int? height,
) async {
  final byteData = await generateKhmerTextImageFor80mm(segments, width, height);

  if (byteData == null) {
    return null;
  }

  final uint8List = byteData.buffer.asUint8List();
  return img.decodePng(uint8List);
}

// Font sizes optimized for 80mm paper
double _getFontSizeFor80mm(KhmerFontSize fontSize) {
  switch (fontSize) {
    case KhmerFontSize.small:
      return 14.0; // Larger than 58mm
    case KhmerFontSize.normal:
      return 18.0;
    case KhmerFontSize.large:
      return 24.0;
    case KhmerFontSize.extraLarge:
      return 30.0;
  }
}

// Helper functions (same as before)
FontWeight _getFontWeight(KhmerTextStyle style) {
  switch (style) {
    case KhmerTextStyle.bold:
    case KhmerTextStyle.boldItalic:
      return FontWeight.bold;
    case KhmerTextStyle.normal:
    case KhmerTextStyle.italic:
      return FontWeight.normal;
  }
}

FontStyle _getFontStyle(KhmerTextStyle style) {
  switch (style) {
    case KhmerTextStyle.italic:
    case KhmerTextStyle.boldItalic:
      return FontStyle.italic;
    case KhmerTextStyle.normal:
    case KhmerTextStyle.bold:
      return FontStyle.normal;
  }
}

// Enum definitions
enum KhmerTextStyle { normal, bold, italic, boldItalic }

enum KhmerFontSize { small, normal, large, extraLarge }

class StyledTextSegment {
  final String text;
  final KhmerTextStyle style;
  final KhmerFontSize fontSize;
  final Color? color;
  final int maxline;
  final bool isDescription;
  final double? columnWidth;

  StyledTextSegment({
    required this.text,
    this.style = KhmerTextStyle.normal,
    this.fontSize = KhmerFontSize.normal,
    this.color,
    this.maxline = 2,
    this.isDescription = false,
    this.columnWidth,
  });
}

// XP-P323B specific configurations
class XP323BConfig {
  static const PaperSize paperSize = PaperSize.mm80;
  static const int paperWidthPixels = 576; // Standard for 80mm thermal
  static const double maxPrintSpeed = 70; // mm/sec as per specs
  static const int leftMargin = 20;
  static const int topMargin = 30;

  // Print settings optimized for XP-P323B
  static const Map<String, dynamic> printSettings = {
    'paperSize': PaperSize.mm80,
    'width': 576,
    'fontSizeMultiplier': 1.2, // Larger fonts for 80mm
    'margins': {'left': 20, 'top': 30, 'right': 20, 'bottom': 10},
  };
}

// import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image/image.dart' as img;
// import 'package:salesforce/core/enums/enums.dart';
// import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/styled_text_segment.dart';

// import 'package:salesforce/theme/app_colors.dart' as Colors;
// import 'dart:ui' as ui;

// Future<List<int>> generateThermalReceipt(
//   List<StyledTextSegment> segments,
// ) async {
//   const PaperSize paper = PaperSize.mm58;
//   final profile = await CapabilityProfile.load();
//   final generator = Generator(paper, profile);
//   List<int> bytes = [];

//   // String longKhmerText =longKhmerText
//   //     """សួស្ដី! Helloខ្ញុំសង្ឃឹមថាអ្នកមានសុខភាពល្អ។ នេះជាការសាកល្បងបោះពុម្ពអក្សរខ្មែរ។ អរគុណច្រើនសម្រាប់ការទិញទំនិញ។ សូមទំនាក់ទំនងមកយើងខ្ញុំ ប្រសិនបើអ្នកមានសំណួរ។ យើងខ្ញុំនឹងបម្រើអ្នកដោយក្ដីស្រលាញ់។ នេះជាការសាកល្បងបោះពុម្ពអក្សរខ្មែរ។ អរគុណច្រើនសម្រាប់ការទិញទំនិញ។ សូមទំនាក់ទំនងមកយើងខ្ញុំ ប្រសិនបើអ្នកមានសំណួរ។អរគុណច្រើនសម្រាប់ការទិញទំនិញ។""";

//   final khmerBytes = await printKhmerText(segments ?? []);
//   bytes.addAll(khmerBytes);

//   bytes += generator.feed(1);
//   bytes += generator.cut();

//   return bytes;
// }

// Future<List<int>> printKhmerText(List<StyledTextSegment> segments) async {
//   final profile = await CapabilityProfile.load();
//   final generator = Generator(
//     PaperSize.mm58,
//     profile,
//   ); // Use same paper size as main receipt

//   List<int> bytes = [];

//   // Calculate proper dimensions for 58mm paper (approximately 384 pixels wide)
//   const int paperWidthPixels = 384;

//   // Generate image with proper dimensions and text wrapping
//   final image = await generateKhmerTextAsImgImage(
//     paperWidthPixels,
//     null,
//     segments,
//   );

//   if (image != null) {
//     // Convert image into printer bytes
//     bytes += generator.image(image);
//   }

//   // Minimal feed space
//   bytes += generator.feed(1);

//   return bytes;
// }

// Future<ByteData?> generateKhmerTextImageWithCanvas(
//   List<StyledTextSegment> segments,
//   int width,
//   int? height, // Make height optional for auto-calculation
// ) async {
//   final recorder = ui.PictureRecorder();

//   List<TextSpan> textSpans = segments.map((segment) {
//     return TextSpan(
//       text: segment.text,
//       style: TextStyle(
//         fontFamily: 'Siemreap',
//         fontSize: _getFontSize(segment.fontSize),
//         fontWeight: _getFontWeight(segment.style),
//         fontStyle: _getFontStyle(segment.style),
//         color: segment.color ?? Colors.dark,
//         height: 1.3, // Line height
//       ),
//     );
//   }).toList();
//   // Create TextPainter first to calculate required height
//   final textPainter = TextPainter(
//     text: TextSpan(children: textSpans),
//     textDirection: TextDirection.ltr,
//     maxLines: null,
//     textAlign: TextAlign.left,
//   );

//   // Layout with width constraint to enable text wrapping
//   textPainter.layout(maxWidth: width.toDouble() - 20); // Leave margins

//   // Calculate height if not provided
//   final calculatedHeight =
//       height ?? (textPainter.height + 24).ceil(); // Add padding

//   final canvas = ui.Canvas(
//     recorder,
//     ui.Rect.fromLTWH(0, 0, width.toDouble(), calculatedHeight.toDouble()),
//   );

//   // Fill background
//   final paint = ui.Paint()..color = Colors.white;
//   canvas.drawRect(
//     ui.Rect.fromLTWH(0, 0, width.toDouble(), calculatedHeight.toDouble()),
//     paint,
//   );

//   // Paint text with proper alignment and marginsx
//   textPainter.paint(
//     canvas,
//     const ui.Offset(10, 20), // Left margin and top padding
//   );

//   // Convert to image
//   final picture = recorder.endRecording();
//   final uiImage = await picture.toImage(width, calculatedHeight);
//   final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);

//   return byteData;
// }

// Future<img.Image?> generateKhmerTextAsImgImage(
//   int width,
//   int? height,
//   List<StyledTextSegment> segments,
// ) async {
//   final byteData = await generateKhmerTextImageWithCanvas(
//     segments,
//     width,
//     height,
//   );

//   if (byteData == null) {
//     return null;
//   }

//   final uint8List = byteData.buffer.asUint8List();
//   return img.decodePng(uint8List);
// }

// double _getFontSize(KhmerFontSize fontSize) {
//   switch (fontSize) {
//     case KhmerFontSize.small:
//       return 12.0;
//     case KhmerFontSize.normal:
//       return 16.0;
//     case KhmerFontSize.large:
//       return 20.0;
//     case KhmerFontSize.extraLarge:
//       return 24.0;
//   }
// }

// FontWeight _getFontWeight(KhmerTextStyle style) {
//   switch (style) {
//     case KhmerTextStyle.bold:
//     case KhmerTextStyle.boldItalic:
//       return FontWeight.bold;
//     case KhmerTextStyle.normal:
//     case KhmerTextStyle.italic:
//       return FontWeight.normal;
//   }
// }

// FontStyle _getFontStyle(KhmerTextStyle style) {
//   switch (style) {
//     case KhmerTextStyle.italic:
//     case KhmerTextStyle.boldItalic:
//       return FontStyle.italic;
//     case KhmerTextStyle.normal:
//     case KhmerTextStyle.bold:
//       return FontStyle.normal;
//   }
// }

// // Convenience function for simple styled text
// StyledTextSegment createStyledText(
//   String text, {
//   bool bold = false,
//   bool italic = false,
//   KhmerFontSize fontSize = KhmerFontSize.normal,
//   Color? color,
// }) {
//   KhmerTextStyle style;
//   if (bold && italic) {
//     style = KhmerTextStyle.boldItalic;
//   } else if (bold) {
//     style = KhmerTextStyle.bold;
//   } else if (italic) {
//     style = KhmerTextStyle.italic;
//   } else {
//     style = KhmerTextStyle.normal;
//   }

//   return StyledTextSegment(
//     text: text,
//     style: style,
//     fontSize: fontSize,
//     color: color,
//   );
// }

//==================asdfasd=ff==============================
Future<List<int>> generateThermalReceiptold() async {
  const PaperSize paper = PaperSize.mm58;
  final profile = await CapabilityProfile.load();
  final generator = Generator(paper, profile);
  List<int> bytes = [];

  // Store header
  bytes += generator.text(
    'Nk Kim yang POSHOEI Sangkat Tuek L\'ak 1',
    styles: PosStyles(
      align: PosAlign.center,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ),
  );

  // bytes += generator.text(
  //   'Khan Toul Kork, Phnom Penh',
  //   styles: PosStyles(align: PosAlign.center),
  // );

  // bytes += generator.text(
  //   'Tel: 098 870 102 A02 405 357',
  //   styles: PosStyles(align: PosAlign.center),
  // );

  // bytes += generator.text(
  //   '#ទីប្រជុំ Nk Kim yang',
  //   styles: PosStyles(align: PosAlign.center),
  // );

  // bytes += generator.text(
  //   '17-04-2025 14:48',
  //   styles: PosStyles(align: PosAlign.center),
  // );

  // bytes += generator.text(
  //   'BILL B05750507',
  //   styles: PosStyles(align: PosAlign.center, bold: true),
  // );

  // // Separator line
  // bytes += generator.text('================================');

  // // Customer section
  // bytes += generator.text('Customer');
  // bytes += generator.text('Sale Date');
  // bytes += generator.text('Invoice No');

  // bytes += generator.text('================================');

  // // Item header with proper column formatting
  // bytes += generator.row([
  //   PosColumn(text: '*', width: 1),
  //   PosColumn(text: 'Description', width: 7),
  //   PosColumn(text: 'Qty', width: 2),
  //   PosColumn(text: 'Price', width: 2),
  // ]);

  // bytes += generator.text('--------------------------------');

  // // Items with aligned columns
  // bytes += generator.row([
  //   PosColumn(text: '1', width: 1),
  //   PosColumn(text: 'Phkh0716', width: 7),
  //   PosColumn(
  //     text: '2',
  //     width: 2,
  //     styles: PosStyles(align: PosAlign.center),
  //   ),
  //   PosColumn(
  //     text: '0.25',
  //     width: 2,
  //     styles: PosStyles(align: PosAlign.right),
  //   ),
  // ]);

  // bytes += generator.row([
  //   PosColumn(text: '2', width: 1),
  //   PosColumn(text: 'Rep1001', width: 7),
  //   PosColumn(
  //     text: '1',
  //     width: 2,
  //     styles: PosStyles(align: PosAlign.center),
  //   ),
  //   PosColumn(
  //     text: '0.5',
  //     width: 2,
  //     styles: PosStyles(align: PosAlign.right),
  //   ),
  // ]);

  // bytes += generator.row([
  //   PosColumn(text: '3', width: 1),
  //   PosColumn(text: 'Mmtoy', width: 7),
  //   PosColumn(
  //     text: '1',
  //     width: 2,
  //     styles: PosStyles(align: PosAlign.center),
  //   ),
  //   PosColumn(
  //     text: '0.63',
  //     width: 2,
  //     styles: PosStyles(align: PosAlign.right),
  //   ),
  // ]);

  // bytes += generator.row([
  //   PosColumn(text: '4', width: 1),
  //   PosColumn(text: 'Tp end', width: 7),
  //   PosColumn(
  //     text: '1',
  //     width: 2,
  //     styles: PosStyles(align: PosAlign.center),
  //   ),
  //   PosColumn(
  //     text: '0.5',
  //     width: 2,
  //     styles: PosStyles(align: PosAlign.right),
  //   ),
  // ]);

  // bytes += generator.row([
  //   PosColumn(text: '5', width: 1),
  //   PosColumn(text: 'FLOlphakla (B)', width: 7),
  //   PosColumn(
  //     text: '1',
  //     width: 2,
  //     styles: PosStyles(align: PosAlign.center),
  //   ),
  //   PosColumn(
  //     text: '3.5',
  //     width: 2,
  //     styles: PosStyles(align: PosAlign.right),
  //   ),
  // ]);

  // bytes += generator.row([
  //   PosColumn(text: '6', width: 1),
  //   PosColumn(text: 'SIETHD', width: 7),
  //   PosColumn(
  //     text: '7',
  //     width: 2,
  //     styles: PosStyles(align: PosAlign.center),
  //   ),
  //   PosColumn(
  //     text: '0.13',
  //     width: 2,
  //     styles: PosStyles(align: PosAlign.right),
  //   ),
  // ]);

  // bytes += generator.text('--------------------------------');

  // // Items summary
  // bytes += generator.text('Items purchased: 6     Qty: 13');

  // bytes += generator.text('================================');

  // // Totals section
  // bytes += generator.row([
  //   PosColumn(text: 'Sub-Total', width: 8),
  //   PosColumn(
  //     text: '\$0',
  //     width: 4,
  //     styles: PosStyles(align: PosAlign.right),
  //   ),
  // ]);

  // bytes += generator.row([
  //   PosColumn(text: 'Disc. (0%)', width: 8),
  //   PosColumn(
  //     text: '\$0',
  //     width: 4,
  //     styles: PosStyles(align: PosAlign.right),
  //   ),
  // ]);

  // bytes += generator.row([
  //   PosColumn(text: 'Grand Total', width: 8),
  //   PosColumn(
  //     text: '\$0',
  //     width: 4,
  //     styles: PosStyles(align: PosAlign.right, bold: true),
  //   ),
  // ]);

  // bytes += generator.text('================================');

  // // Payment section
  // bytes += generator.row([
  //   PosColumn(text: 'Received', width: 8),
  //   PosColumn(
  //     text: '\$7',
  //     width: 4,
  //     styles: PosStyles(align: PosAlign.right),
  //   ),
  // ]);

  // bytes += generator.row([
  //   PosColumn(text: 'USD/RFU', width: 8),
  //   PosColumn(
  //     text: '\$25.00',
  //     width: 4,
  //     styles: PosStyles(align: PosAlign.right),
  //   ),
  // ]);

  // bytes += generator.text('================================');

  // // Large amount display
  // bytes += generator.text(
  //   '\$7',
  //   styles: PosStyles(
  //     align: PosAlign.center,
  //     height: PosTextSize.size2,
  //     width: PosTextSize.size2,
  //     bold: true,
  //   ),
  // );

  // bytes += generator.text('');

  // bytes += generator.text(
  //   '\$25.00',
  //   styles: PosStyles(
  //     align: PosAlign.center,
  //     height: PosTextSize.size2,
  //     width: PosTextSize.size2,
  //     bold: true,
  //   ),
  // );

  // bytes += generator.text('================================');

  // // QR Code section
  // bytes += generator.text(
  //   '***Scan here to pay by KHOR***',
  //   styles: PosStyles(align: PosAlign.center, bold: true),
  // );

  // bytes += generator.text('');

  // // QR Code placeholders - replace with actual QR images
  // bytes += generator.text(
  //   '[QR CODE 1]',
  //   styles: PosStyles(align: PosAlign.center),
  // );

  // bytes += generator.text('');

  // bytes += generator.text(
  //   '[QR CODE 2]',
  //   styles: PosStyles(align: PosAlign.center),
  // );

  // bytes += generator.text('');

  // // Footer information
  // bytes += generator.text(
  //   'Account Name: Basile STM by SIM DNA',
  //   styles: PosStyles(align: PosAlign.left),
  // );

  // bytes += generator.text('');

  // bytes += generator.text(
  //   'Thanks for buying at our shop',
  //   styles: PosStyles(align: PosAlign.center),
  // );

  // bytes += generator.text(
  //   'please come again',
  //   styles: PosStyles(align: PosAlign.center),
  // );

  // bytes += generator.text('');

  // bytes += generator.text(
  //   'Payment Methods',
  //   styles: PosStyles(align: PosAlign.center),
  // );

  // Feed and cut
  bytes += generator.feed(3);
  bytes += generator.cut();

  return bytes;
}

// Function to add QR code image (when you have the image)
// Future<List<int>> generateReceiptWithQR(
//   img.Image? qrImage1,
//   img.Image? qrImage2,
// ) async {
//   const PaperSize paper = PaperSize.mm58;
//   final profile = await CapabilityProfile.load();
//   final generator = Generator(paper, profile);
//   List<int> bytes = [];

//   // ... (same header code as above) ...

//   // Store header
//   bytes += generator.text(
//     'POSHOEI Sangkat Tuek L\'ak 1',
//     styles: PosStyles(align: PosAlign.center),
//   );

//   // ... (include all the middle content from above) ...

//   // QR Code section with actual images
//   bytes += generator.text(
//     '***Scan here to pay by KHOR***',
//     styles: PosStyles(align: PosAlign.center, bold: true),
//   );

//   if (qrImage1 != null) {
//     bytes += generator.image(qrImage1, align: PosAlign.center);
//   }

//   if (qrImage2 != null) {
//     bytes += generator.image(qrImage2, align: PosAlign.center);
//   }

//   // Footer
//   bytes += generator.text(
//     'Account Name: Basile STM by SIM DNA',
//     styles: PosStyles(align: PosAlign.left),
//   );

//   bytes += generator.text(
//     'Thanks for buying at our shop please come again',
//     styles: PosStyles(align: PosAlign.center),
//   );

//   bytes += generator.feed(3);
//   bytes += generator.cut();

//   return bytes;
// }
