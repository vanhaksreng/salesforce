// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:image/image.dart' as img;
// import 'package:path_provider/path_provider.dart';
// // Optional: For saving to gallery
// // import 'package:image_gallery_saver/image_gallery_saver.dart';

// class ReceiptPrinter {
//   // buildReceiptWidget (unchanged, with LayoutBuilder for better sizing)
//   static Widget buildReceiptWidget(List<Map<String, dynamic>> items) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Container(
//           width: constraints.maxWidth,
//           padding: const EdgeInsets.all(8),
//           color: Colors.white, // Clean background
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'ប្លូតិចឡូជី', // Khmer
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'KhmerFont',
//                   ),
//                 ),
//                 const Text(
//                   'BLUE TECHNOLOGY CO., LTD',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 Table(
//                   border: TableBorder.all(color: Colors.black),
//                   defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//                   children: [
//                     const TableRow(
//                       children: [
//                         // Headers
//                         Text('Description', style: TextStyle(fontSize: 12)),
//                         Text('Qty', style: TextStyle(fontSize: 12)),
//                         Text('UOM', style: TextStyle(fontSize: 12)),
//                         Text('Price', style: TextStyle(fontSize: 12)),
//                         Text('Disc', style: TextStyle(fontSize: 12)),
//                         Text('Amount', style: TextStyle(fontSize: 12)),
//                       ],
//                     ),
//                     ...items.map(
//                       (item) => TableRow(
//                         children: [
//                           // Dynamic rows
//                           Text(
//                             item['description'] ?? '',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               fontFamily: 'NotoSansKhmer',
//                             ),
//                           ),
//                           Text(
//                             item['qty'].toString(),
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                           Text(
//                             item['uom'] ?? '',
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                           Text(
//                             item['price'].toString(),
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                           Text(
//                             item['disc'].toString(),
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                           Text(
//                             item['amount'].toString(),
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20), // Footer
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // NEW: Off-screen capture via positioned Stack in Overlay (fixes type/assertion errors)
//   static Future<ui.Image?> _captureImageOffScreen(
//     BuildContext context,
//     List<Map<String, dynamic>> items,
//   ) async {
//     final GlobalKey _boundaryKey = GlobalKey();
//     final Completer<ui.Image?> completer = Completer<ui.Image?>();
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double pixelRatio = MediaQuery.of(context).devicePixelRatio;


//   /// Render text widget to image
//   static Future<img.Image> _renderTextToImage(
//     String text, {
//     required double fontSize,
//     required int paperWidth,
//     required FontWeight fontWeight,
//     required double lineHeight,
//   }) async {
//     // Create text painter
//     final textSpan = TextSpan(
//       text: text,
//       style: TextStyle(
//         color: Colors.black,
//         fontSize: fontSize,
//         fontWeight: fontWeight,
//         height: lineHeight, // Use adjustable line height
//       ),
//     );

//     final textPainter = TextPainter(
//       text: textSpan,
//       textDirection: TextDirection.ltr,
//       maxLines: null,
//     );

//     // Wait for layout/paint, then capture
//     SchedulerBinding.instance.addPostFrameCallback((_) async {
//       try {
//         // Short delay for full render (fonts/table)
//         await Future.delayed(const Duration(milliseconds: 50));

//         final RenderRepaintBoundary boundary =
//             _boundaryKey.currentContext!.findRenderObject()
//                 as RenderRepaintBoundary;
//         final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);

//         debugPrint(
//           'Captured off-screen image: ${image.width} x ${image.height}',
//         );

//         if (image.width == 0 || image.height == 0) {
//           image.dispose();
//           completer.completeError(
//             Exception('Invalid dimensions: ${image.width}x${image.height}'),
//           );
//           return;
//         }

//         completer.complete(image);
//       } catch (e) {
//         completer.completeError(e);
//       } finally {
//         overlayEntry.remove(); // Always cleanup
//       }
//     });

//     final height = textPainter.height.ceil() + 10; // Less vertical padding

//     // Create picture recorder
//     final recorder = ui.PictureRecorder();
//     final canvas = Canvas(recorder);

//     // White background
//     canvas.drawRect(
//       Rect.fromLTWH(0, 0, paperWidth.toDouble(), height.toDouble()),
//       Paint()..color = Colors.white,
//     );

//     // Draw text
//     textPainter.paint(canvas, const Offset(8, 5)); // Less padding

//     // Convert to image
//     final picture = recorder.endRecording();
//     final uiImage = await picture.toImage(paperWidth, height);
//     final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);

//     // Convert to image package format
//     final pngBytes = byteData!.buffer.asUint8List();
//     final decodedImage = img.decodeImage(pngBytes)!;

//     // Convert to monochrome (black and white only)
//     final bwImage = img.grayscale(decodedImage);

//     return bwImage;
//   }

//   // _uiImageToMonochrome (unchanged)
//   static Future<Uint8List> _uiImageToMonochrome(
//     ui.Image uiImage,
//     int width,
//     int height,
//   ) async {
//     final byteWidth = (width + 7) ~/ 8;
//     final totalBytes = byteWidth * height;
//     final List<int> bitmap = List<int>.filled(totalBytes, 0);

//     final ByteData? tempByteData = await uiImage.toByteData(
//       format: ui.ImageByteFormat.rawRgba,
//     );
//     if (tempByteData == null) {
//       throw Exception('Failed to convert image to ByteData');
//     }
//     final ByteData byteData = tempByteData;
//     final pixels = byteData.buffer.asUint8List();

//     final commands = <int>[];

//     // ESC @ - Initialize printer
//     commands.addAll([0x1B, 0x40]);

//     // Set line spacing to minimum for tighter output
//     commands.addAll([0x1B, 0x33, 0x00]);

//     // Process image line by line using ESC * command
//     for (int y = 0; y < height; y++) {
//       // ESC * m nL nH d1...dk
//       // m = 33 (24-dot double-density) - better quality
//       commands.addAll([
//         0x1B, 0x2A, 0x21, // ESC * 33 (24-dot double-density)
//         bytesPerLine & 0xFF, // nL - low byte
//         (bytesPerLine >> 8) & 0xFF, // nH - high byte
//       ]);

//       // Convert pixels to bytes
//       final lineBytes = <int>[];
//       for (int x = 0; x < adjustedWidth; x += 8) {
//         int byte = 0;
//         for (int bit = 0; bit < 8; bit++) {
//           final pixelX = x + bit;
//           if (pixelX < width) {
//             final pixel = image.getPixel(pixelX, y);
//             final luminance = img.getLuminance(pixel);
//             // Black pixel if luminance < 128
//             if (luminance < 128) {
//               byte |= (0x80 >> bit); // Set bit from left to right
//             }
//           }
//         }
//       }
//     }

//     return Uint8List.fromList(bitmap);
//   }

//   // _bitmapToEscPos (unchanged)
//   static Uint8List _bitmapToEscPos(Uint8List bitmap, int width, int height) {
//     final byteWidth = (width + 7) ~/ 8;

//     final List<int> escPos = [0x1B, 0x40]; // ESC @ init

//     escPos.addAll([0x1D, 0x76, 0x30, 0]); // GS v 0 m=0
//     escPos.add(byteWidth & 0xFF); // xL
//     escPos.add((byteWidth >> 8) & 0xFF); // xH
//     escPos.add(height & 0xFF); // yL
//     escPos.add((height >> 8) & 0xFF); // yH

//     escPos.addAll(bitmap);

//     escPos.add(0x0A); // LF
//     escPos.addAll([0x1D, 0x56, 0x42, 0x00]); // Partial cut

//     return Uint8List.fromList(escPos);
//   }

//   // UPDATED: Main print function—now passes context to off-screen capture
//   static Future<void> printReceipt(
//     BuildContext context,
//     List<Map<String, dynamic>> items,
//   ) async {
//     if (!context.mounted) return;

//     try {
//       final ui.Image? image = await _captureImageOffScreen(context, items);
//       if (image == null) {
//         throw Exception('Failed to capture receipt image');
//       }

//       final width = image.width;
//       final height = image.height;

//       final bitmap = await _uiImageToMonochrome(image, width, height);
//       final escPosBytes = _bitmapToEscPos(bitmap, width, height);

//       if (BluetoothPrinterHandler.isConnected) {
//         await BluetoothPrinterHandler.printRaw(escPosBytes);
//       } else {
//         throw Exception('Printer not connected');
//       }

//       image.dispose();
//     } catch (e) {
//       print('❌ Error saving image: $e');
//       return null;
//     }
//   }
// }
