// // khmer_pos_printer.dart - Comprehensive Khmer language support for POS printing

// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:image/image.dart' as img;

// /// Model for receipt items
// class ReceiptItem {
//   final String description;
//   final String quantity;
//   final String unit;
//   final String price;
//   final String discount;
//   final String amount;

//   ReceiptItem({
//     required this.description,
//     required this.quantity,
//     required this.unit,
//     required this.price,
//     required this.discount,
//     required this.amount,
//   });
// }

// /// Model for receipt header
// class ReceiptHeader {
//   final String companyNameKhmer;
//   final String companyNameEnglish;
//   final String? address;
//   final String? phone;
//   final String? taxId;

//   ReceiptHeader({
//     required this.companyNameKhmer,
//     required this.companyNameEnglish,
//     this.address,
//     this.phone,
//     this.taxId,
//   });
// }

// /// ESC/POS command constants
// class EscPosCommands {
//   // Printer Control
//   static const List<int> initPrinter = [0x1B, 0x40]; // ESC @
//   static const List<int> resetPrinter = [0x1B, 0x40]; // ESC @
  
//   // Text Formatting
//   static const List<int> selectFontA = [0x1B, 0x4D, 0x00]; // ESC M 0
//   static const List<int> selectFontB = [0x1B, 0x4D, 0x01]; // ESC M 1
//   static const List<int> boldOn = [0x1B, 0x45, 0x01]; // ESC E 1
//   static const List<int> boldOff = [0x1B, 0x45, 0x00]; // ESC E 0
//   static const List<int> underlineOn = [0x1B, 0x2D, 0x01]; // ESC - 1
//   static const List<int> underlineOff = [0x1B, 0x2D, 0x00]; // ESC - 0
//   static const List<int> doubleSizeOn = [0x1B, 0x21, 0x10]; // ESC ! 16
//   static const List<int> doubleSizeOff = [0x1B, 0x21, 0x00]; // ESC ! 0
  
//   // Alignment
//   static const List<int> alignLeft = [0x1B, 0x61, 0x00]; // ESC a 0
//   static const List<int> alignCenter = [0x1B, 0x61, 0x01]; // ESC a 1
//   static const List<int> alignRight = [0x1B, 0x61, 0x02]; // ESC a 2
  
//   // Line operations
//   static const List<int> lineFeed = [0x0A]; // LF
//   static const List<int> carriageReturn = [0x0D]; // CR
  
//   // Cutting
//   static const List<int> partialCut = [0x1D, 0x56, 0x42, 0x00]; // GS V B 0
//   static const List<int> fullCut = [0x1D, 0x56, 0x41, 0x00]; // GS V A 0
// }

// /// Print preview data structure
// class PrintPreviewData {
//   final img.Image image;
//   final Uint8List printCommands;
//   final String textContent;

//   PrintPreviewData({
//     required this.image,
//     required this.printCommands,
//     required this.textContent,
//   });
// }

// /// Khmer-specific thermal printer helper
// class KhmerThermalPrinter {
  
//   /// Convert text to ESC/POS image commands with Khmer support
//   /// Supports Khmer, English, and mixed languages
//   static Future<PrintPreviewData> convertTextToImageCommands(
//     String text, {
//     double fontSize = 24,
//     int paperWidth = 384, // 48mm paper (384 dots)
//     FontWeight fontWeight = FontWeight.normal,
//     double lineHeight = 1.2,
//   }) async {
//     // Render text to image
//     final image = await _renderTextToImage(
//       text,
//       fontSize: fontSize,
//       paperWidth: paperWidth,
//       fontWeight: fontWeight,
//       lineHeight: lineHeight,
//     );

//     // Convert to ESC/POS bitmap commands
//     final commands = _convertToESCPOSBitmap(image);

//     return PrintPreviewData(
//       image: image,
//       printCommands: commands,
//       textContent: text,
//     );
//   }

//   /// Render text widget to image with Khmer support
//   static Future<img.Image> _renderTextToImage(
//     String text, {
//     required double fontSize,
//     required int paperWidth,
//     required FontWeight fontWeight,
//     required double lineHeight,
//   }) async {
//     // Create text painter with Khmer font support
//     final textSpan = TextSpan(
//       text: text,
//       style: TextStyle(
//         color: Colors.black,
//         fontSize: fontSize,
//         fontWeight: fontWeight,
//         height: lineHeight,
//         fontFamily: 'NotoSansKhmer', // Primary Khmer font
//         fontFamilyFallback: const ['NotoSansKhmer', 'Siemreap', 'Roboto'],
//       ),
//     );

//     final textPainter = TextPainter(
//       text: textSpan,
//       textDirection: TextDirection.ltr,
//       maxLines: null,
//       strutStyle: StrutStyle(
//         fontFamily: 'NotoSansKhmer',
//         fontSize: fontSize,
//         height: lineHeight,
//       ),
//     );

//     textPainter.layout(maxWidth: paperWidth.toDouble() - 16);

//     final height = textPainter.height.ceil() + 10;

//     // Create picture recorder
//     final recorder = ui.PictureRecorder();
//     final canvas = Canvas(recorder);

//     // White background
//     canvas.drawRect(
//       Rect.fromLTWH(0, 0, paperWidth.toDouble(), height.toDouble()),
//       Paint()..color = Colors.white,
//     );

//     // Draw text
//     textPainter.paint(canvas, const Offset(8, 5));

//     // Convert to image
//     final picture = recorder.endRecording();
//     final uiImage = await picture.toImage(paperWidth, height);
//     final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);

//     final pngBytes = byteData!.buffer.asUint8List();
//     final decodedImage = img.decodeImage(pngBytes)!;

//     // Convert to monochrome for thermal printing
//     return _applyThresholdFilter(decodedImage);
//   }

//   /// Apply binary threshold for better thermal printing
//   static img.Image _applyThresholdFilter(img.Image image) {
//     final threshold = 192; // Threshold for black/white conversion
//     final filtered = img.Image.from(image);

//     for (int y = 0; y < image.height; y++) {
//       for (int x = 0; x < image.width; x++) {
//         final pixel = image.getPixel(x, y);
//         final lum = img.getLuminance(pixel);

//         final newPixel = lum < threshold
//             ? img.ColorRgb8(0, 0, 0)      // Black
//             : img.ColorRgb8(255, 255, 255); // White

//         filtered.setPixel(x, y, newPixel);
//       }
//     }

//     return filtered;
//   }

//   /// Convert image to ESC/POS bitmap commands
//   static Uint8List _convertToESCPOSBitmap(img.Image image) {
//     final width = image.width;
//     final height = image.height;
//     final bytesPerLine = (width + 7) ~/ 8;

//     final commands = <int>[];

//     // Initialize printer
//     commands.addAll(EscPosCommands.initPrinter);

//     // Process image line by line
//     for (int y = 0; y < height; y++) {
//       // ESC * m nL nH - Bit image mode
//       commands.addAll([
//         0x1B, 0x2A, 0x21, // m=33 (8-dot triple density)
//         bytesPerLine & 0xFF,
//         (bytesPerLine >> 8) & 0xFF,
//       ]);

//       // Convert pixels to bitmap bytes
//       for (int x = 0; x < width; x += 8) {
//         int byte = 0;
//         for (int bit = 0; bit < 8; bit++) {
//           if (x + bit < width) {
//             final pixel = image.getPixel(x + bit, y);
//             final luminance = img.getLuminance(pixel);
//             if (luminance < 192) {
//               byte |= (1 << (7 - bit));
//             }
//           }
//         }
//         commands.add(byte);
//       }

//       // Line feed
//       commands.add(0x0A);
//     }

//     // Add line feeds and partial cut
//     commands.add(0x0A);
//     commands.addAll(EscPosCommands.partialCut);

//     return Uint8List.fromList(commands);
//   }

//   /// Create a complete receipt with Khmer text
//   static Future<PrintPreviewData> createKhmerReceipt({
//     required ReceiptHeader header,
//     required List<ReceiptItem> items,
//     String? footerText,
//     double fontSize = 18,
//     int paperWidth = 384,
//   }) async {
//     final buffer = StringBuffer();

//     // Header
//     buffer.writeln(header.companyNameKhmer);
//     buffer.writeln(header.companyNameEnglish);
    
//     if (header.address != null) {
//       buffer.writeln(header.address!);
//     }
//     if (header.phone != null) {
//       buffer.writeln('ទូរស័ព្ទ: ${header.phone}');
//     }
//     if (header.taxId != null) {
//       buffer.writeln('អាយ.ឌ: ${header.taxId}');
//     }

//     buffer.writeln();
//     buffer.writeln('=====================================');

//     // Items header
//     buffer.writeln('នាម        បរិមាណ   តម្លៃ    សរុប');
//     buffer.writeln('=====================================');

//     // Items
//     double totalAmount = 0;
//     for (var item in items) {
//       // Try to parse amount
//       try {
//         totalAmount += double.parse(item.amount);
//       } catch (e) {
//         // Ignore parsing errors
//       }

//       buffer.writeln(_formatReceiptLine(
//         description: item.description,
//         quantity: item.quantity,
//         price: item.price,
//         amount: item.amount,
//       ));
//     }

//     buffer.writeln('=====================================');
//     buffer.writeln('សរុប: ${totalAmount.toStringAsFixed(2)}');
//     buffer.writeln('=====================================');

//     if (footerText != null) {
//       buffer.writeln();
//       buffer.writeln(footerText);
//     }

//     buffer.writeln();
//     buffer.writeln('សូមអរគុណ - Thank You!');

//     return await convertTextToImageCommands(
//       buffer.toString(),
//       fontSize: fontSize,
//       paperWidth: paperWidth,
//       lineHeight: 1.1,
//       fontWeight: FontWeight.bold,
//     );
//   }

//   /// Format receipt line with proper spacing
//   static String _formatReceiptLine({
//     required String description,
//     required String quantity,
//     required String price,
//     required String amount,
//   }) {
//     // Adjust spacing for Khmer characters (which take more space)
//     return '${description.padRight(18)} ${quantity.padLeft(3)} ${price.padLeft(6)} ${amount.padLeft(7)}';
//   }

//   /// Create simple text-based Khmer receipt (for printers that don't support images)
//   static Uint8List createTextReceipt({
//     required ReceiptHeader header,
//     required List<ReceiptItem> items,
//     String? footerText,
//   }) {
//     final buffer = StringBuffer();

//     // Initialize printer
//     buffer.write(String.fromCharCodes(EscPosCommands.initPrinter));

//     // Center alignment
//     buffer.write(String.fromCharCodes(EscPosCommands.alignCenter));

//     // Header
//     buffer.writeln(header.companyNameKhmer);
//     buffer.writeln(header.companyNameEnglish);

//     if (header.address != null) {
//       buffer.writeln(header.address!);
//     }
//     if (header.phone != null) {
//       buffer.writeln('ទូរស័ព្ទ: ${header.phone}');
//     }

//     // Left alignment for items
//     buffer.write(String.fromCharCodes(EscPosCommands.alignLeft));
//     buffer.writeln();
//     buffer.writeln('=====================================');
//     buffer.writeln('នាម        បរិមាណ   តម្លៃ    សរុប');
//     buffer.writeln('=====================================');

//     // Items
//     for (var item in items) {
//       buffer.writeln(_formatReceiptLine(
//         description: item.description,
//         quantity: item.quantity,
//         price: item.price,
//         amount: item.amount,
//       ));
//     }

//     buffer.writeln('=====================================');
    
//     // Center and print footer
//     buffer.write(String.fromCharCodes(EscPosCommands.alignCenter));
    
//     if (footerText != null) {
//       buffer.writeln(footerText);
//     }
//     buffer.writeln('សូមអរគុណ - Thank You!');

//     // Cut paper
//     buffer.write(String.fromCharCodes(EscPosCommands.partialCut));

//     return Uint8List.fromList(utf8.encode(buffer.toString()));
//   }

//   /// Convert img.Image to Flutter Image widget
//   static ImageProvider imageToProvider(img.Image image) {
//     final pngBytes = img.encodePng(image);
//     return MemoryImage(Uint8List.fromList(pngBytes));
//   }
// }

// /// Print preview dialog widget
// class KhmerPrintPreviewDialog extends StatelessWidget {
//   final PrintPreviewData previewData;
//   final VoidCallback onPrint;
//   final String? title;

//   const KhmerPrintPreviewDialog({
//     Key? key,
//     required this.previewData,
//     required this.onPrint,
//     this.title,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         constraints: const BoxConstraints(maxWidth: 500),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Title
//             Text(
//               title ?? 'ពិនិត្យប្រិនសិប្បនិមិត្ត - Print Preview',
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'NotoSansKhmer',
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Preview Image
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade300),
//                 color: Colors.white,
//               ),
//               constraints: const BoxConstraints(maxHeight: 400),
//               child: SingleChildScrollView(
//                 child: Image(
//                   image: KhmerThermalPrinter.imageToProvider(previewData.image),
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Info
//             Text(
//               'ទំហំ: ${previewData.image.width}x${previewData.image.height}px',
//               style: TextStyle(
//                 color: Colors.grey.shade600,
//                 fontSize: 11,
//                 fontFamily: 'NotoSansKhmer',
//               ),
//             ),
//             Text(
//               'ទិន្នន័យ: ${previewData.printCommands.length} bytes',
//               style: TextStyle(
//                 color: Colors.grey.shade600,
//                 fontSize: 11,
//                 fontFamily: 'NotoSansKhmer',
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text(
//                     'ביטול - Cancel',
//                     style: TextStyle(fontFamily: 'NotoSansKhmer'),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                     onPrint();
//                   },
//                   icon: const Icon(Icons.print),
//                   label: const Text(
//                     'ព្រីន - Print',
//                     style: TextStyle(fontFamily: 'NotoSansKhmer'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
